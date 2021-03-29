defmodule Unicode.Transform.Rule.Conversion do
  @moduledoc """
  #### 10.3.9 [Conversion Rules](https://unicode.org/reports/tr35/tr35-general.html#Conversion_Rules)

  Conversion rules can be forward, backward, or double. The complete conversion rule syntax is described below:

  **Forward**

  > A forward conversion rule is of the following form:
  > ```
  > before_context { text_to_replace } after_context → completed_right | right_to_revisit ;
  > ```
  > If there is no before_context, then the "{" can be omitted. If there is no after_context, then the "}" can be omitted. If there is no right_to_revisit, then the "|" can be omitted. A forward conversion rule is only executed for the normal transform and is ignored when generating the inverse transform.

  **Backward**

  > A backward conversion rule is of the following form:
  > ```
  > completed_right | right_to_revisit ← before_context { text_to_replace } after_context ;
  > ```
  > The same omission rules apply as in the case of forward conversion rules. A backward conversion rule is only executed for the inverse transform and is ignored when generating the normal transform.

  **Dual**

  > A dual conversion rule combines a forward conversion rule and a backward conversion rule into one, as discussed above. It is of the form:
  >
  > ```
  > a { b | c } d ↔ e { f | g } h ;
  > ```
  >
  > When generating the normal transform and the inverse, the revisit mark "|" and the left and after contexts are ignored on the sides where they do not belong. Thus, the above is exactly equivalent to the sequence of the following two rules:
  >
  > ```
  > a { b c } d → f | g  ;
  > b | c  ←  e { f g } h ;
  > ```

  #### 10.3.10 <a name="Intermixing_Transform_Rules_and_Conversion_Rules" href="#Intermixing_Transform_Rules_and_Conversion_Rules">Intermixing Transform Rules and Conversion Rules</a>

  Transform rules and conversion rules may be freely intermixed. Inserting a transform rule into the middle of a set of conversion rules has an important side effect.

  Normally, conversion rules are considered together as a group.  The only time their order in the rule set is important is when more than one rule matches at the same point in the string.  In that case, the one that occurs earlier in the rule set wins.  In all other situations, when multiple rules match overlapping parts of the string, the one that matches earlier wins.

  Transform rules apply to the whole string.  If you have several transform rules in a row, the first one is applied to the whole string, then the second one is applied to the whole string, and so on.  To reconcile this behavior with the behavior of conversion rules, transform rules have the side effect of breaking a surrounding set of conversion rules into two groups: First all of the conversion rules left the transform rule are applied as a group to the whole string in the usual way, then the transform rule is applied to the whole string, and then the conversion rules after the transform rule are applied as a group to the whole string.  For example, consider the following rules:

  ```
  abc → xyz;
  xyz → def;
  ::Upper;
  ```

  If you apply these rules to “abcxyz”, you get “XYZDEF”. If you move the “::Upper;” to the middle of the rule set and change the cases accordingly, then applying this to “abcxyz” produces “DEFDEF”.

  ```
  abc → xyz;
  ::Upper;
  XYZ → DEF;
  ```

  This is because “::Upper;” causes the transliterator to reset to the beginning of the string. The first rule turns the string into “xyzxyz”, the second rule upper cases the whole thing to “XYZXYZ”, and the third rule turns this into “DEFDEF”.

  This can be useful when a transform naturally occurs in multiple “passes.”  Consider this rule set:

  ```
  [:Separator:]* → ' ';
  'high school' → 'H.S.';
  'middle school' → 'M.S.';
  'elementary school' → 'E.S.';
  ```

  If you apply this rule to “high school”, you get “H.S.”, but if you apply it to “high  school” (with two spaces), you just get “high school” (with one space). To have “high school” (with two spaces) turn into “H.S.”, you'd either have to have the first rule back up some arbitrary distance (far enough to see “elementary”, if you want all the rules to work), or you have to include the whole left-hand side of the first rule in the other rules, which can make them hard to read and maintain:

  ```
  $space = [:Separator:]*;
  high $space school → 'H.S.';
  middle $space school → 'M.S.';
  elementary $space school → 'E.S.';
  ```

  Instead, you can simply insert “ `::Null;` ” in order to get things to work right:

  ```
  [:Separator:]* → ' ';
  ::Null;
  'high school' → 'H.S.';
  'middle school' → 'M.S.';
  'elementary school' → 'E.S.';
  ```

  The “::Null;” has no effect of its own (the null transform, by definition, does not do anything), but it splits the other rules into two “passes”: The first rule is applied to the whole string, normalizing all runs of white space into single spaces, and then we start over at the beginning of the string to look for the phrases. “high    school” (with four spaces) gets correctly converted to “H.S.”.

  This can also sometimes be useful with rules that have overlapping domains.  Consider this rule set from left:

  ```
  sch → sh ;
  ss → z ;
  ```

  Apply this rule to “bassch” rights in “bazch” because “ss” matches earlier in the string than “sch”. If you really wanted “bassh”—that is, if you wanted the first rule to win even when the second rule matches earlier in the string, you'd either have to add another rule for this special case...

  ```
  sch → sh ;
  ssch → ssh;
  ss → z ;
  ```

  ...or you could use a transform rule to apply the conversions in two passes:

  ```
  sch → sh ;
  ::Null;
  ss → z ;
  ```
  """

  @direction_symbols ["→", "←", "↔"]
  @directions ~r/(?<!\\)[#{Enum.join(@direction_symbols)}]/u

  @fields [:direction, :left, :right, :comment]
  defstruct @fields

  alias Unicode.Transform.Rule.Comment

  def parse(rule) when is_binary(rule) do
    if Regex.match?(@directions, rule) do
      parse_binary(rule)
    else
      nil
    end
  end

  def parse_binary(rule) do
    [rule, comment] =
      case String.split(rule, ~r/(?<!')#/, parts: 2) do
        [rule] -> [rule, nil]
        [rule, comment] -> [rule, String.trim(comment)]
      end

    parsed =
      rule
      |> String.trim()
      |> String.split(~r/(?<!')[;]/u, include_captures: true)
      |> parse_rule()

    struct(__MODULE__, Enum.zip(@fields, parsed) |> Keyword.put(:comment, comment))
  end

  def parse_rule(rule) when is_binary(rule) do
    rule
    |> String.trim()
    |> String.split(@directions, include_captures: true)
    |> parse_rule()
  end

  def parse_rule([rule]) do
    rule
    |> String.trim()
    |> String.replace_trailing(";", "")
    |> parse_rule()
  end

  def parse_rule([rule, ";", ""]) do
    rule
    |> String.trim()
    |> parse_rule()
  end

  # Forward rule
  def parse_rule([left, "→", right]) do
    parse_rule(left, right, :forward)
  end

  # Backward rule
  def parse_rule([right, "←", left]) do
    parse_rule(left, right, :backward)
  end

  # Both rule
  def parse_rule([left, "↔", right]) do
    parse_rule(left, right, :both)
  end

  def parse_rule(left, right, direction) do
    left = parse_side(left)
    right = parse_side(right)

    [direction, left, right]
  end

  def parse_side(side) when is_binary(side) do
    side
    |> String.trim()
    |> split_at_syntax()
    |> parse_side()
    |> trim()
  end

  def parse_side([before_context, "{", replace, "|", revisit, "}", after_context]) do
    [before_context, replace, revisit, after_context]
  end

  def parse_side([before_context, "{", replace, "}", after_context]) do
    [before_context, replace, nil, after_context]
  end

  def parse_side([before_context, "{", replace, "|", revisit]) do
    [before_context, replace, revisit, nil]
  end

  def parse_side([before_context, "{", replace]) do
    [before_context, replace, nil, nil]
  end

  def parse_side([replace, "|", revisit, "}", after_context]) do
    [nil, replace, revisit, after_context]
  end

  def parse_side([replace, "}", after_context]) do
    [nil, replace, nil, after_context]
  end

  def parse_side([replace]) do
    [nil, replace, nil, nil]
  end

  # Splits on syntax chars except within string
  # between ' (single quote) characters
  def split_at_syntax(string, acc \\ [""])

  def split_at_syntax("", acc) do
    Enum.reverse(acc)
  end

  def split_at_syntax(<<"\\u", hex::binary-4>> <> string, [head | rest]) do
    split_at_syntax(string, [head <> "\\u" <> hex | rest])
  end

  def split_at_syntax(<<"\\{">> <> string, [head | rest]) do
    split_at_syntax(string, [head <> "\\{" | rest])
  end

  def split_at_syntax(<<"\\}">> <> string, [head | rest]) do
    split_at_syntax(string, [head <> "\\}" | rest])
  end

  def split_at_syntax(<<"\\|">> <> string, [head | rest]) do
    split_at_syntax(string, [head <> "\\|" | rest])
  end

  def split_at_syntax(<<"\\'">> <> string, [head | rest]) do
    split_at_syntax(string, [head <> "\\'" | rest])
  end

  def split_at_syntax(<<"'">> <> string, [head | rest]) do
    {quoted_string, remainder} = extract_quoted(string)
    split_at_syntax(remainder, [head <> quoted_string | rest])
  end

  def split_at_syntax(<<"{">> <> string, [head | rest]) do
    split_at_syntax(string, ["", "{", head | rest])
  end

  def split_at_syntax(<<"}">> <> string, [head | rest]) do
    split_at_syntax(string, ["", "}", head | rest])
  end

  def split_at_syntax(<<"|">> <> string, [head | rest]) do
    split_at_syntax(string, ["", "|", head | rest])
  end

  def split_at_syntax(<<char::utf8>> <> string, [head | rest]) do
    split_at_syntax(string, [head <> <<char::utf8>> | rest])
  end

  def extract_quoted(string, acc \\ "")

  def extract_quoted("", acc) do
    {acc, ""}
  end

  def extract_quoted(<<"\\'">> <> rest, acc) do
    extract_quoted(rest, acc <> "'")
  end

  def extract_quoted(<<"'">> <> rest, acc) do
    {acc, rest}
  end

  def extract_quoted(<<char::utf8>> <> rest, acc) do
    extract_quoted(rest, acc <> <<char::utf8>>)
  end

  def trim(list) do
    Enum.map(list, fn
      nil -> nil
      other -> String.trim(other)
    end)
  end

  def code_options(nil, nil),
    do: []

  def code_options(before_context, nil),
    do: [preceeded_by: before_context]

  def code_options(nil, after_context),
    do: [followed_by: after_context]

  def code_options(before_context, after_context),
    do: [preceeded_by: before_context, followed_by: after_context]

  def code_args(from, nil), do: from
  def code_args(from, extra), do: from <> extra

  defimpl Unicode.Transform.Rule do
    def to_forward_code(%{left: left, right: right} = rule) do
      [before_context, from, extra, after_context] = left
      [_, to, revisit, _] = right

      from = Unicode.Transform.Rule.Conversion.code_args(from, extra)
      options = Unicode.Transform.Rule.Conversion.code_options(before_context, after_context)
      options = if revisit, do: Keyword.put(options, :revisit, revisit), else: options

      base_code = [
        Comment.comment_from(rule),
        "replace(",
        wrap(from),
        ", ",
        wrap(to),
      ]

      if options == [] do
        [base_code, ")", "\n"]
      else
        [base_code, ", ", inspect(options), ")", "\n"]
      end
    end

    def to_backward_code(_rule) do
      []
    end

    defp wrap(string) do
      "\"" <> string <> "\""
    end
  end
end

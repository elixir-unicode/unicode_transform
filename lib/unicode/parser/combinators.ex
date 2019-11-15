defmodule Unicode.Transform.Combinators do
  @doc """
  Parses a transliteration rule set.

  ## Transliteration rules

  The following describes the full format of the list of rules
  used to create a transform. Each rule in the list is terminated
  by a semicolon. The list consists of the following:

  * an optional filter rule
  * zero or more transform rules
  * zero or more variable-definition rules
  * zero or more conversion rules
  * an optional inverse filter rule

  ## Filter rules

  A filter rule consists of two colons followed by a UnicodeSet.
  This filter is global in that only the characters matching the
  filter will be affected by any transform rules or conversion
  rules. The inverse filter rule consists of two colons followed
  by a UnicodeSet in parentheses. This filter is also global for
  the inverse transform.

  For example, the Hiragana-Latin transform can be implemented
  by "pivoting" through the Katakana converter, as follows:

  ```
  :: [:^Katakana:] ; # do not touch any katakana that was in the text!
  :: Hiragana-Katakana;
  :: Katakana-Latin;
  :: ([:^Katakana:]) ; # do not touch any katakana that was in the text
                       # for the inverse either!
  ```

  The filters keep the transform from mistakenly converting any of
  the "pivot" characters. Note that this is a case where a rule list
  contains no conversion rules at all, just transform rules and filters.

  ## Transform rules

  Each transform rule consists of two colons followed by a transform
  name, which is of the form source-target. For example:

  ```
  :: NFD ;
  :: und_Latn-und_Greek ;
  :: Latin-Greek; # alternate form
  ```

  If either the source or target is 'und', it can be omitted, thus 'und_NFC'
  is equivalent to 'NFC'. For compatibility, the English names for scripts
  can be used instead of the und_Latn locale name, and "Any" can be used
  instead of "und". Case is not significant.

  The following transforms are defined not by rules, but by the operations
  in the Unicode Standard, and may be used in building any other transform:

  `Any-NFC`, `Any-NFD`, `Any-NFKD`, `Any-NFKC` - the normalization forms
  defined by [UAX15].

  `Any-Lower`, `Any-Upper`, `Any-Title` - full case transformations, defined
  by [Unicode] Chapter 3.
  ```

  In addition, the following special cases are defined:

  ```
  Any-Null - has no effect; that is, each character is left alone.
  Any-Remove - maps each character to the empty string; this, removes each character.
  ```

  The inverse of a transform rule uses parentheses to indicate what should
  be done when the inverse transform is used. For example:

  ```
  :: lower () ; # only executed for the normal
  :: (lower) ; # only executed for the inverse
  :: lower ; # executed for both the normal and the inverse
  ```

  ## Variable definition rules

  Each variable definition is of the following form:

  ```
  $variableName = contents ;
  ```

  The variable name can contain letters and digits, but must start
  with a letter. More precisely, the variable names use Unicode
  identifiers as defined by [UAX31]. The identifier properties allow
  for the use of foreign letters and numbers.

  The contents of a variable definition is any sequence of Unicode
  sets and characters or characters. For example:

  ```
  $mac = M [aA] [cC] ;
  ```

  Variables are only replaced within other variable definition
  rules and within conversion rules. They have no effect on
  transliteration rules.

  ## Conversion Rules

  Conversion rules can be forward, backward, or double. The complete
  conversion rule syntax is described below:

  ### Forward

  A forward conversion rule is of the following form:

  ```
  before_context { text_to_replace } after_context → completed_result | result_to_revisit ;
  ```

  If there is no `before_context`, then the `{` can be omitted. If there is no
  `after_context`, then the `}` can be omitted. If there is no result_to_revisit,
  then the `|` can be omitted. A forward conversion rule is only executed
  for the normal transform and is ignored when generating the inverse transform.

  ### Backward

  A backward conversion rule is of the following form:

  ```
  completed_result | result_to_revisit ← before_context { text_to_replace } after_context ;
  ```

  The same omission rules apply as in the case of forward conversion rules.
  A backward conversion rule is only executed for the inverse transform and
  is ignored when generating the normal transform.

  ### Dual

  A dual conversion rule combines a forward conversion rule and a backward
  conversion rule into one, as discussed above. It is of the form:

  ```
  a { b | c } d ↔ e { f | g } h ;
  ```

  When generating the normal transform and the inverse, the revisit mark
  `|` and the before and after contexts are ignored on the sides where they
  do not belong. Thus, the above is exactly equivalent to the sequence of
  the following two rules:

  ```
  a { b c } d  →  f | g  ;
  b | c  ←  e { f g } h ;
  ```

  ## Intermixing Transform Rules and Conversion Rules

  Transform rules and conversion rules may be freely intermixed.
  Inserting a transform rule into the middle of a set of conversion
  rules has an important side effect.

  Normally, conversion rules are considered together as a group.
  The only time their order in the rule set is important is when
  more than one rule matches at the same point in the string.  In
  that case, the one that occurs earlier in the rule set wins.  In
  all other situations, when multiple rules match overlapping parts
  of the string, the one that matches earlier wins.

  Transform rules apply to the whole string.  If you have several
  transform rules in a row, the first one is applied to the whole string,
  then the second one is applied to the whole string, and so on.  To
  reconcile this behavior with the behavior of conversion rules, transform
  rules have the side effect of breaking a surrounding set of conversion
  rules into two groups: First all of the conversion rules before the
  transform rule are applied as a group to the whole string in the usual
  way, then the transform rule is applied to the whole string, and then
  the conversion rules after the transform rule are applied as a group to
  the whole string.  For example, consider the following rules:

  ```
  abc → xyz;
  xyz → def;
  ::Upper;
  ```

  If you apply these rules to `abcxyz`, you get `XYZDEF`.  If you move
  the `::Upper;` to the middle of the rule set and change the cases
  accordingly, then applying this to `abcxyz` produces `DEFDEF`.

  ```
  abc → xyz;
  ::Upper;
  XYZ → DEF;
  ```

  This is because `::Upper;` causes the transliterator to reset
  to the beginning of the string. The first rule turns the string
  into `xyzxyz`, the second rule upper cases the whole thing to `XYZXYZ`,
  and the third rule turns this into `DEFDEF`.

  This can be useful when a transform naturally occurs in multiple “passes.”
  Consider this rule set:

  ```
  [:Separator:]* → ' ';
  'high school' → 'H.S.';
  'middle school' → 'M.S.';
  'elementary school' → 'E.S.';
  ```

  If you apply this rule to `high school`, you get `H.S.`, but if you apply
  it to `high  school` (with two spaces), you just get `high school` (with
  one space). To have `high  school` (with two spaces) turn into `H.S.`,
  you'd either have to have the first rule back up some arbitrary distance
  (far enough to see `elementary`, if you want all the rules to work), or you
  have to include the whole left-hand side of the first rule in the other rules,
  which can make them hard to read and maintain:

  ```
  $space = [:Separator:]*;
  high $space school → 'H.S.';
  middle $space school → 'M.S.';
  elementary $space school → 'E.S.';
  ```

  Instead, you can simply insert `::Null;` in order to get things to work right:

  ```
  [:Separator:]* → ' ';
  ::Null;
  'high school' → 'H.S.';
  'middle school' → 'M.S.';
  'elementary school' → 'E.S.';
  ```

  The `::Null;` has no effect of its own (the null transform, by definition,
  does not do anything), but it splits the other rules into two “passes”: The
  first rule is applied to the whole string, normalizing all runs of white space
  into single spaces, and then we start over at the beginning of the string to
  look for the phrases. `high    school` (with four spaces) gets correctly converted
  to `H.S.`.

  This can also sometimes be useful with rules that have overlapping domains.
  Consider this rule set from before:

  ```
  sch → sh ;
  ss → z ;
  ```

  Apply this rule to `bassch` results in `bazch` because `ss` matches earlier
  in the string than `sch`. If you really wanted `bassh`—that is, if you wanted
  the first rule to win even when the second rule matches earlier in the string,
  you'd either have to add another rule for this special case...

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

  import NimbleParsec

  script_names =
    Unicode.Script.scripts()
    |> Map.keys()
    |> Enum.map(&String.replace(&1, "_", " "))
    |> Enum.map(fn s -> String.split(s) |> Enum.map(&String.capitalize/1) |> Enum.join end)
    |> Enum.map(fn script ->
      quote do
        string(unquote(script))
      end
    end)

  def character_class do
    ignore(string("["))
    |> choice([
      block(),
      canonical_combining_class(),
      script(),
      category(),
      characters()
    ])
    |> ignore(string("]"))
  end

  def script do
    ignore(string(":"))
    |> ignore(optional(string("script=")))
    |> concat(script_name())
    |> ignore(string(":"))
    |> unwrap_and_tag(:script)
  end

  def block do
    ignore(string(":"))
    |> ignore(string("block="))
    |> concat(name())
    |> ignore(string(":"))
    |> unwrap_and_tag(:block)
  end

  def category do
    ignore(string(":"))
    |> concat(name())
    |> ignore(string(":"))
    |> unwrap_and_tag(:category)
  end

  def canonical_combining_class do
    ignore(string(":"))
    |> ignore(string("ccc="))
    |> concat(name())
    |> ignore(string(":"))
    |> unwrap_and_tag(:combining_class)
  end

  def characters do
    utf8_char([{:not, ?]}])
    |> times(min: 1)
    |> tag(:character_class)
  end

  # Example: [[:Arabic:][:block=ARABIC:][‎ⁿ،؛؟ـً-ٕ٠-٬۰-۹﷼ښ]] ;
  def unicode_set do
    ignore(string("["))
    |> times(character_class(), min: 1)
    |> ignore(string("]"))
  end

  def whitespace do
    ascii_char([?\s, ?\t])
    |> repeat()
  end

  def name do
    optional(ascii_char([?^]))
    |> times(ascii_char([?a..?z, ?A..?Z, ?\s]), min: 1)
    |> reduce(:to_lower_atom)
  end

  def script_name do
    choice(unquote(script_names))
  end

  def to_lower_atom([?^ | args]) do
    {:not, to_lower_atom(args)}
  end

  def to_lower_atom(args) do
    args
    |> List.to_string()
    |> String.replace(" ", "_")
    |> String.downcase()
    |> String.to_atom()
  end

  def filter_rule do
    ignore(string("::"))
    |> ignore(optional(whitespace()))
    |> choice([
      unicode_set(),
      character_class()
    ])
    |> concat(end_of_rule())
    |> tag(:filter_rule)
  end

  def end_of_rule do
    ignore(optional(whitespace()))
    |> ignore(string(";"))
    |> ignore(optional(whitespace()))
    |> ignore(optional(comment()))
  end

  def comment do
    string("#")
    |> repeat(utf8_char([]))
    |> eos()
  end

  def transform_rule do
    ignore(string("::"))
    |> ignore(optional(whitespace()))
    |> choice([
      both_transform(),
      forward_transform(),
      inverse_transform()
    ])
    |> concat(end_of_rule())
    |> tag(:transform)
  end

  def forward_transform do
    transform_name()
    |> unwrap_and_tag(:forward_transform)
  end

  def inverse_transform do
    ignore(string("("))
    |> ignore(optional(whitespace()))
    |> optional(transform_name() |> unwrap_and_tag(:inverse_transform))
    |> ignore(optional(whitespace()))
    |> ignore(string(")"))
  end

  def both_transform do
    forward_transform()
    |> ignore(optional(whitespace()))
    |> concat(inverse_transform())
  end

  def transform_name do
    times(ascii_char([?a..?z, ?A..?Z, ?-, ?_]), min: 1)
    |> reduce({List, :to_string, []})
  end

  def variable_definition do
    ignore(string("$"))
    |> concat(variable_name())
    |> ignore(optional(whitespace()))
    |> ignore(string("="))
    |> ignore(optional(whitespace()))
    |> concat(variable_value())
    |> concat(end_of_rule())
    |> tag(:set_variable)
  end

  def variable_name do
    utf8_char([?a..?z, ?A..?Z])
    |> repeat(utf8_char([{:not, ?\s}, {:not, ?\t}]))
    |> reduce({List, :to_string, []})
    |> unwrap_and_tag(:variable_name)
  end

  def variable_value do
    characters_or_class()
    |> repeat(ignore(optional(whitespace())) |> concat(characters_or_class()))
    |> tag(:value)
  end

  def characters_or_class do
    choice([
      unicode_set(),
      character_class(),
      ignore(string("$")) |> concat(variable_name()),
      character_string()
    ])
  end

  def character_string do
    one_character()
    |> times(min: 1)
    |> reduce(:to_string)
    |> unwrap_and_tag(:string)
  end

  def one_character do
    choice([
      ignore(string("\\")) |> utf8_char([]),
      ignore(string("'")) |> concat(encoded_character()) |> ignore(string("'")),
      ignore(string("'")) |> repeat(utf8_char([{:not, ?'}])) |> ignore(string("'")),
      utf8_char([{:not, ?[}, {:not, ?;}, {:not, ?\s}])
    ])
  end

  def encoded_character do
    choice([
      ignore(string("\\u"))
      |> times(ascii_char([?a..?f, ?A..?F, 0..9]), 4),
      ignore(string("\\x{"))
      |> times(ascii_char([?a..?f, ?A..?F, 0..9]), min: 1, max: 4)
      |> ignore(string("}"))
    ])
    |> reduce(:hex_to_integer)
  end

  def hex_to_integer(chars) do
    chars
    |> List.to_string()
    |> String.to_integer(16)
  end
end

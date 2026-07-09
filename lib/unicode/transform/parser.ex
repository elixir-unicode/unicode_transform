defmodule Unicode.Transform.Parser do
  @moduledoc """
  Parses CLDR transform rule text into structured rule types.

  The parser handles the five rule types defined by the
  [CLDR specification](https://unicode.org/reports/tr35/tr35-general.html#Rule_Syntax):

  * Comment rules — lines starting with `#`.

  * Filter rules — `:: [unicode_set] ;`.

  * Transform rules — `:: transform_name ;`.

  * Variable definition rules — `$var = value ;`.

  * Conversion rules — with `→`, `←`, or `↔` operators.

  """

  alias Unicode.Transform.Rule.{Comment, Conversion, Definition, Filter, Transform}

  @direction_chars ["→", "←", "↔"]
  # A conversion rule uses a Unicode arrow (→ ← ↔) or the equivalent ICU ASCII
  # operator (> < <>). The lookbehind excludes an escaped or quoted operator.
  @direction_regex ~r/(?<![\\'])(<>|[<>→←↔])/u

  @doc """
  Parses a complete rule text string into a list of rule structs.

  ### Arguments

  * `rule_text` — the raw rule text from a CLDR transform XML file.

  ### Returns

  A list of rule structs.

  """
  @spec parse(String.t()) :: [struct()]
  def parse(rule_text) do
    rule_text
    |> strip_bidi_controls()
    |> split_rules()
    |> Enum.map(&parse_rule/1)
    |> Enum.reject(&is_nil/1)
  end

  @doc """
  Parses a single rule string into a rule struct.

  ### Arguments

  * `rule_string` — a single rule line.

  ### Returns

  A rule struct or `nil` for empty/unparseable lines.

  """
  @spec parse_rule(String.t()) :: struct() | nil
  def parse_rule(rule_string) do
    trimmed = String.trim(rule_string)

    cond do
      trimmed == "" ->
        nil

      String.starts_with?(trimmed, "#") ->
        parse_comment(trimmed)

      String.starts_with?(trimmed, "$") && String.contains?(trimmed, "=") ->
        parse_definition(trimmed)

      String.starts_with?(trimmed, "::") ->
        parse_directive(trimmed)

      Regex.match?(@direction_regex, trimmed) ->
        parse_conversion(trimmed)

      true ->
        parse_comment(trimmed)
    end
  end

  # Bidi formatting controls (LRM U+200E, RLM U+200F, ALM U+061C) sometimes appear
  # as invisible editing artifacts in CLDR rule text (e.g. the Uyghur and
  # Arabic/Hebrew rules); ICU ignores them when parsing rules, so we strip them
  # before parsing. This is applied to the RULE TEXT only, never to the input being
  # transformed. ZWJ/ZWNJ (U+200C/U+200D) are deliberately NOT stripped — they are
  # legitimate output in some transforms. A rule that genuinely emits an LRM/RLM
  # uses the \u200E escape, which survives (only the literal character is removed).
  defp strip_bidi_controls(text) do
    String.replace(text, ["\u200E", "\u200F", "\u061C"], "")
  end

  # Split the rule text into individual rule strings.
  # Rules are terminated by semicolons, but semicolons inside
  # quoted strings or character classes don't count.
  defp split_rules(text) do
    text
    |> join_bracketed_lines()
    |> String.split("\n")
    |> Enum.map(&String.trim/1)
    |> Enum.flat_map(&split_line_at_semicolons/1)
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
  end

  # A newline inside a `[...]` set (a multi-line variable/set definition) is not a
  # statement boundary — replace it with a space so the set is parsed as one unit.
  # Tracks quote and escape state so a `[` in a comment/quote does not miscount
  # bracket depth, and leaves comments (`#` to end of line) and their newlines intact.
  defp join_bracketed_lines(text), do: do_join_bracketed(text, 0, false, "")

  defp do_join_bracketed("", _depth, _quoted, acc), do: acc

  defp do_join_bracketed(<<"\\", char::utf8, rest::binary>>, depth, quoted, acc) do
    do_join_bracketed(rest, depth, quoted, acc <> "\\" <> <<char::utf8>>)
  end

  # Track `'` quoting only OUTSIDE a set: inside `[...]` a `'` is a literal set
  # member (e.g. the apostrophe in `[',.A-Za-z]`), and toggling quote state there
  # would swallow the closing `]` and collapse the rest of the file into the set.
  defp do_join_bracketed(<<"'", rest::binary>>, 0, quoted, acc) do
    do_join_bracketed(rest, 0, not quoted, acc <> "'")
  end

  # A `#` comment (outside a set and outside quotes) runs to the end of the line;
  # consume it verbatim so brackets inside it never affect depth.
  defp do_join_bracketed(<<"#", rest::binary>>, 0, false, acc) do
    {comment, rest} =
      case :binary.split(rest, "\n") do
        [comment, after_newline] -> {comment, "\n" <> after_newline}
        [comment] -> {comment, ""}
      end

    do_join_bracketed(rest, 0, false, acc <> "#" <> comment)
  end

  defp do_join_bracketed(<<"[", rest::binary>>, depth, false, acc) do
    do_join_bracketed(rest, depth + 1, false, acc <> "[")
  end

  defp do_join_bracketed(<<"]", rest::binary>>, depth, false, acc) do
    do_join_bracketed(rest, max(depth - 1, 0), false, acc <> "]")
  end

  defp do_join_bracketed(<<"\n", rest::binary>>, depth, quoted, acc) when depth > 0 do
    do_join_bracketed(rest, depth, quoted, acc <> " ")
  end

  defp do_join_bracketed(<<char::utf8, rest::binary>>, depth, quoted, acc) do
    do_join_bracketed(rest, depth, quoted, acc <> <<char::utf8>>)
  end

  defp split_line_at_semicolons(line) do
    do_split_line(line, "", [])
  end

  defp do_split_line("", current, acc) do
    case String.trim(current) do
      "" -> Enum.reverse(acc)
      trimmed -> Enum.reverse([trimmed | acc])
    end
  end

  # Escaped character
  defp do_split_line(<<"\\", char::utf8, rest::binary>>, current, acc) do
    do_split_line(rest, current <> "\\" <> <<char::utf8>>, acc)
  end

  # Quoted string
  defp do_split_line(<<"'", rest::binary>>, current, acc) do
    {quoted, remainder} = extract_quoted(rest)
    do_split_line(remainder, current <> "'" <> quoted <> "'", acc)
  end

  # Character class
  defp do_split_line(<<"[", rest::binary>>, current, acc) do
    {class, remainder} = extract_character_class(rest, 1)
    do_split_line(remainder, current <> "[" <> class, acc)
  end

  # Comment - rest of line is part of this rule
  defp do_split_line(<<"#", rest::binary>>, current, acc) do
    do_split_line("", current <> "#" <> rest, acc)
  end

  # Semicolon - rule boundary
  defp do_split_line(<<";", rest::binary>>, current, acc) do
    case String.trim(current) do
      "" -> do_split_line(rest, "", acc)
      trimmed -> do_split_line(rest, "", [trimmed | acc])
    end
  end

  defp do_split_line(<<char::utf8, rest::binary>>, current, acc) do
    do_split_line(rest, current <> <<char::utf8>>, acc)
  end

  # Parse a comment line
  defp parse_comment(<<"#", rest::binary>>) do
    %Comment{text: String.trim(rest)}
  end

  defp parse_comment(text) do
    %Comment{text: text}
  end

  # Parse a variable definition: $var = value ;
  #
  # CLDR variable names are Unicode identifiers, not just ASCII — for example the
  # Ethiopic transforms define `$ግዕዝ = 'a'`. The name class must therefore admit
  # any letter/mark/number plus underscore, or those definitions are silently
  # dropped and their references pass through unresolved.
  #
  # The value uses `.*` (not `.+`): CLDR defines empty variables (`$x = ;`, e.g.
  # the SERA/ES3842 Ethiopic word-final vowel markers) which must register with an
  # empty value so their references resolve to "" instead of leaking `$x` verbatim.
  defp parse_definition(rule) do
    case Regex.run(
           ~r/^\$([\p{L}_][\p{L}\p{M}\p{N}_]*)\s*=\s*(.*)$/u,
           strip_comment_and_semicolon(rule)
         ) do
      [_, variable, value] ->
        %Definition{variable: variable, value: String.trim(value)}

      _ ->
        %Comment{text: rule}
    end
  end

  # Parse a directive (filter or transform): :: ... ;
  defp parse_directive(rule) do
    content =
      rule
      |> String.trim_leading("::")
      |> String.trim()
      |> strip_comment_and_semicolon()
      |> String.trim()

    cond do
      # Inverse filter: :: ([unicode_set]) ;
      Regex.match?(~r/^\(\s*\[/, content) ->
        unicode_set =
          content
          |> String.trim_leading("(")
          |> String.trim_trailing(")")
          |> String.trim()

        %Filter{unicode_set: unicode_set, direction: :inverse}

      # Forward filter `:: [set] ;`, or a filtered transform `:: [set] Name ;`.
      String.starts_with?(content, "[") ->
        parse_filter_directive(content)

      # Transform with forward and backward: :: forward (backward) ;
      Regex.match?(~r/\(/, content) ->
        parse_transform_directive(content)

      # Simple transform: :: name ;
      true ->
        name = String.trim(content)

        if name == "" do
          nil
        else
          %Transform{forward: name, backward: name}
        end
    end
  end

  # A directive that begins with a `[set]` is either a bare global filter
  # (`:: [set] ;`) or a filtered transform (`:: [set] Name ;`). Strip the leading
  # balanced set: if a transform name follows, emit that transform (the set only
  # restricts which characters it sees, which is redundant for the transforms that
  # use this form); otherwise it is a plain forward filter.
  defp parse_filter_directive(<<"[", rest::binary>>) do
    {class, remainder} = extract_character_class(rest, 1)

    case String.trim(remainder) do
      "" ->
        %Filter{unicode_set: "[" <> class, direction: :forward}

      name ->
        if String.contains?(name, "("),
          do: parse_transform_directive(name),
          else: %Transform{forward: name, backward: name}
    end
  end

  defp parse_transform_directive(content) do
    case Regex.run(~r/^([A-Za-z_-]*)\s*\(\s*([A-Za-z_-]*)\s*\)$/u, content) do
      [_, forward, backward] ->
        %Transform{
          forward: if(forward == "", do: nil, else: forward),
          backward: if(backward == "", do: nil, else: backward)
        }

      _ ->
        %Transform{forward: content, backward: content}
    end
  end

  # Parse a conversion rule with → ← or ↔
  defp parse_conversion(rule) do
    {rule_text, _comment} = split_comment(rule)
    rule_text = strip_semicolon(String.trim(rule_text))

    case split_at_direction(rule_text) do
      {left_str, "→", right_str} ->
        %Conversion{
          direction: :forward,
          left: parse_side(left_str),
          right: parse_side(right_str)
        }

      {left_str, "←", right_str} ->
        # For backward rules, the right side has the source pattern
        %Conversion{
          direction: :backward,
          left: parse_side(right_str),
          right: parse_side(left_str)
        }

      {left_str, "↔", right_str} ->
        %Conversion{
          direction: :both,
          left: parse_side(left_str),
          right: parse_side(right_str)
        }

      _ ->
        %Comment{text: rule}
    end
  end

  # Split a rule string at the direction operator, respecting quotes and character classes
  defp split_at_direction(string) do
    do_split_direction(string, "")
  end

  defp do_split_direction("", _acc), do: nil

  # Escaped character
  defp do_split_direction(<<"\\"::utf8, char::utf8, rest::binary>>, acc) do
    do_split_direction(rest, acc <> "\\" <> <<char::utf8>>)
  end

  # Quoted string
  defp do_split_direction(<<"'"::utf8, rest::binary>>, acc) do
    {quoted, remainder} = extract_quoted(rest)
    do_split_direction(remainder, acc <> "'" <> quoted <> "'")
  end

  # Character class
  defp do_split_direction(<<"["::utf8, rest::binary>>, acc) do
    {class, remainder} = extract_character_class(rest, 1)
    do_split_direction(remainder, acc <> "[" <> class)
  end

  # Direction operators
  for dir <- @direction_chars do
    defp do_split_direction(<<unquote(dir)::utf8, rest::binary>>, acc) do
      {String.trim(acc), unquote(dir), String.trim(rest)}
    end
  end

  # ICU ASCII operators, normalized to the Unicode arrow so parse_conversion needs
  # no further change. `<>` must be tried before `<`. These sit after the escape,
  # quote and `[...]` clauses above, so a literal/quoted/in-set `<`/`>` is untouched.
  defp do_split_direction(<<"<>", rest::binary>>, acc) do
    {String.trim(acc), "↔", String.trim(rest)}
  end

  defp do_split_direction(<<">", rest::binary>>, acc) do
    {String.trim(acc), "→", String.trim(rest)}
  end

  defp do_split_direction(<<"<", rest::binary>>, acc) do
    {String.trim(acc), "←", String.trim(rest)}
  end

  defp do_split_direction(<<char::utf8, rest::binary>>, acc) do
    do_split_direction(rest, acc <> <<char::utf8>>)
  end

  # Parse one side of a conversion rule into a side map
  defp parse_side(text) do
    text = String.trim(text)
    parts = split_at_syntax(text)
    parse_side_parts(parts)
  end

  defp parse_side_parts(parts) do
    parts = Enum.reject(parts, &(&1 == ""))

    case find_structure(parts) do
      {:full, before_ctx, text_part, revisit, after_ctx} ->
        %{
          before_context: nilify(before_ctx),
          text: text_part,
          revisit: nilify(revisit),
          after_context: nilify(after_ctx)
        }

      :flat ->
        # No braces — check for revisit marker
        case split_revisit(parts) do
          {text_parts, revisit_parts} ->
            {text, after_ctx} =
              text_parts |> Enum.join("") |> String.trim() |> extract_trailing_end_anchor()

            %{
              before_context: nil,
              text: text,
              revisit: Enum.join(revisit_parts, "") |> String.trim() |> nilify(),
              after_context: after_ctx
            }
        end
    end
  end

  # A trailing `$` (or `[$]`) end-anchor in a flat (brace-less) source pattern is
  # not part of the text to match — route it to the after-context so the engine's
  # end-of-text boundary handling applies it (e.g. the Morse rule `([.-])' ' $`).
  # An escaped `\$` is a literal dollar, not an anchor.
  defp extract_trailing_end_anchor(text) do
    cond do
      String.ends_with?(text, "[$]") ->
        {text |> String.replace_suffix("[$]", "") |> String.trim(), "[$]"}

      String.ends_with?(text, "$") and not String.ends_with?(text, "\\$") ->
        {text |> String.replace_suffix("$", "") |> String.trim(), "$"}

      true ->
        {text, nil}
    end
  end

  # Analyze the parts list to find {}, |, and structure
  defp find_structure(parts) do
    brace_open = Enum.find_index(parts, &(&1 == "{"))
    brace_close = Enum.find_index(parts, &(&1 == "}"))

    cond do
      brace_open != nil ->
        before_ctx =
          parts |> Enum.take(brace_open) |> Enum.join("") |> String.trim()

        after_brace_open = Enum.drop(parts, brace_open + 1)

        if brace_close && brace_close > brace_open do
          inner = brace_inner(parts, brace_open, brace_close)
          after_ctx = Enum.drop(parts, brace_close + 1) |> Enum.join("") |> String.trim()

          build_braced_full(before_ctx, inner, after_ctx)
        else
          # No closing brace — everything after { is the text
          {text_parts, revisit_parts} = split_revisit(after_brace_open)
          text_part = Enum.join(text_parts, "") |> String.trim()
          revisit = Enum.join(revisit_parts, "") |> String.trim()
          {:full, before_ctx, text_part, nilify(revisit), nil}
        end

      brace_close != nil ->
        # Closing brace without opening brace: text } after_context
        text_parts = Enum.take(parts, brace_close)
        after_ctx = Enum.drop(parts, brace_close + 1) |> Enum.join("") |> String.trim()

        # Check for revisit in the text part
        {text_parts2, revisit_parts} = split_revisit(text_parts)
        text_part = Enum.join(text_parts2, "") |> String.trim()
        revisit = Enum.join(revisit_parts, "") |> String.trim()
        {:full, nil, text_part, nilify(revisit), nilify(after_ctx)}

      true ->
        :flat
    end
  end

  # Slice the parts between matched braces, or `[]` when the braces are empty.
  defp brace_inner(parts, brace_open, brace_close) when brace_open + 1 <= brace_close - 1 do
    Enum.slice(parts, (brace_open + 1)..(brace_close - 1)//1)
  end

  defp brace_inner(_parts, _brace_open, _brace_close), do: []

  # Build a `:full` structure from the parts inside matched braces, splitting
  # on the optional revisit marker `|`.
  defp build_braced_full(before_ctx, inner, after_ctx) do
    pipe_idx = Enum.find_index(inner, &(&1 == "|"))

    if pipe_idx do
      text_part = Enum.take(inner, pipe_idx) |> Enum.join("") |> String.trim()
      revisit = Enum.drop(inner, pipe_idx + 1) |> Enum.join("") |> String.trim()
      {:full, before_ctx, text_part, revisit, after_ctx}
    else
      text_part = Enum.join(inner, "") |> String.trim()
      {:full, before_ctx, text_part, nil, after_ctx}
    end
  end

  defp split_revisit(parts) do
    pipe_idx = Enum.find_index(parts, &(&1 == "|"))

    if pipe_idx do
      {Enum.take(parts, pipe_idx), Enum.drop(parts, pipe_idx + 1)}
    else
      {parts, []}
    end
  end

  # Split a string at syntax characters ({, }, |) respecting
  # quoted strings, escape sequences, and character classes
  defp split_at_syntax(string) do
    do_split_syntax(string, "", [])
    |> Enum.reverse()
  end

  defp do_split_syntax("", current, acc) do
    [current | acc]
  end

  # Escaped character
  defp do_split_syntax(<<"\\"::utf8, char::utf8, rest::binary>>, current, acc) do
    do_split_syntax(rest, current <> "\\" <> <<char::utf8>>, acc)
  end

  # Quoted string
  defp do_split_syntax(<<"'"::utf8, rest::binary>>, current, acc) do
    {quoted, remainder} = extract_quoted(rest)
    do_split_syntax(remainder, current <> "'" <> quoted <> "'", acc)
  end

  # Character class
  defp do_split_syntax(<<"["::utf8, rest::binary>>, current, acc) do
    {class, remainder} = extract_character_class(rest, 1)
    do_split_syntax(remainder, current <> "[" <> class, acc)
  end

  # Syntax characters
  defp do_split_syntax(<<"{"::utf8, rest::binary>>, current, acc) do
    do_split_syntax(rest, "", ["{", current | acc])
  end

  defp do_split_syntax(<<"}"::utf8, rest::binary>>, current, acc) do
    do_split_syntax(rest, "", ["}", current | acc])
  end

  defp do_split_syntax(<<"|"::utf8, rest::binary>>, current, acc) do
    do_split_syntax(rest, "", ["|", current | acc])
  end

  defp do_split_syntax(<<char::utf8, rest::binary>>, current, acc) do
    do_split_syntax(rest, current <> <<char::utf8>>, acc)
  end

  # Extract a quoted string (between single quotes)
  defp extract_quoted(string, acc \\ "")
  defp extract_quoted("", acc), do: {acc, ""}

  defp extract_quoted(<<"'"::utf8, rest::binary>>, acc) do
    {acc, rest}
  end

  defp extract_quoted(<<char::utf8, rest::binary>>, acc) do
    extract_quoted(rest, acc <> <<char::utf8>>)
  end

  # Extract a character class (between [])
  defp extract_character_class(string, level)
  defp extract_character_class("", _level), do: {"", ""}

  defp extract_character_class(<<"\\[", rest::binary>>, level) do
    {inner, remainder} = extract_character_class(rest, level)
    {"\\[" <> inner, remainder}
  end

  defp extract_character_class(<<"\\]", rest::binary>>, level) do
    {inner, remainder} = extract_character_class(rest, level)
    {"\\]" <> inner, remainder}
  end

  defp extract_character_class(<<"[", rest::binary>>, level) do
    {inner, remainder} = extract_character_class(rest, level + 1)
    {"[" <> inner, remainder}
  end

  defp extract_character_class(<<"]", rest::binary>>, 1) do
    {"]", rest}
  end

  defp extract_character_class(<<"]", rest::binary>>, level) do
    {inner, remainder} = extract_character_class(rest, level - 1)
    {"]" <> inner, remainder}
  end

  defp extract_character_class(<<char::utf8, rest::binary>>, level) do
    {inner, remainder} = extract_character_class(rest, level)
    {<<char::utf8>> <> inner, remainder}
  end

  # Utility functions
  defp nilify(nil), do: nil
  defp nilify(""), do: nil
  defp nilify(s), do: s

  defp strip_comment_and_semicolon(s) do
    s |> split_comment() |> elem(0) |> strip_semicolon() |> String.trim()
  end

  defp strip_semicolon(s) do
    String.trim_trailing(s, ";") |> String.trim()
  end

  defp split_comment(s) do
    do_split_comment(s, "")
  end

  defp do_split_comment("", acc), do: {acc, nil}

  defp do_split_comment(<<"\\"::utf8, char::utf8, rest::binary>>, acc) do
    do_split_comment(rest, acc <> "\\" <> <<char::utf8>>)
  end

  defp do_split_comment(<<"'"::utf8, rest::binary>>, acc) do
    {quoted, remainder} = extract_quoted(rest)
    do_split_comment(remainder, acc <> "'" <> quoted <> "'")
  end

  defp do_split_comment(<<"#"::utf8, rest::binary>>, acc) do
    {acc, String.trim(rest)}
  end

  defp do_split_comment(<<char::utf8, rest::binary>>, acc) do
    do_split_comment(rest, acc <> <<char::utf8>>)
  end
end

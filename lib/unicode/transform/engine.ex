defmodule Unicode.Transform.Engine do
  @moduledoc """
  Executes compiled transforms against input strings.

  The engine implements a cursor-based rewriting algorithm following
  the ICU transliterator design:

  1. For each pass of conversion rules, walk the string from left to right.

  2. At each cursor position, try each rule in order.

  3. When a rule matches, replace the matched text and advance the cursor.

  4. If no rule matches, advance the cursor by one codepoint.

  5. Transform rules are applied to the entire string between passes.

  The engine operates at the codepoint level (not grapheme level) because
  transforms need to process combining marks separately from base characters.

  """

  alias Unicode.Transform.Builtin
  alias Unicode.Transform.Compiler.CompiledTransform
  alias Unicode.Transform.Pattern

  # Cache compiled regexes to avoid recompiling on every match attempt
  @regex_cache_table :unicode_transform_regex_cache

  # Boundary sentinel used for context matching at the start and end of the text.
  # ICU transliteration treats the positions before the first and after the last
  # character as an "anchor" (ETHER): a UnicodeSet such as the word boundary
  # `[^[:L:][:M:][:N:]]` matches there. We reproduce that by matching a start/end
  # context against U+FFFF (a noncharacter that cannot occur in real input) rather
  # than the empty string, so negated-set boundary contexts fire at the text ends.
  @boundary_sentinel <<0xFFFF::utf8>>

  # Some before-contexts require two consecutive edge-matching atoms at the text
  # start (e.g. the Spanish→Arabic word-initial schwa rule `$Boundary [^Vowel]`,
  # where both the boundary anchor and the negated set match the start "ether").
  # A corpus scan shows two is the maximum, so we pad the start with two sentinels.
  # The context regex is suffix-anchored, so the extra sentinel is inert for
  # single-edge contexts and for any non-empty preceding text.
  @boundary_padding @boundary_sentinel <> @boundary_sentinel

  @doc """
  Executes a compiled transform on a string.

  ### Arguments

  * `string` — the input string.

  * `compiled` — a compiled transform struct.

  ### Returns

  The transformed string.

  """
  @spec execute(String.t(), CompiledTransform.t()) :: String.t()
  def execute(string, %CompiledTransform{passes: passes, filter: nil}) do
    execute_passes(passes, string, nil)
  end

  # A global filter (`:: [set] ;`) selects which characters the whole transform
  # touches, across every pass — including sub-transform (`::Foo-Bar;`) and
  # builtin (NFD/NFC) passes, not just conversion rules. ICU's filtered
  # transliteration treats filter-excluded characters as run boundaries and emits
  # them verbatim. We reproduce that by partitioning the input into maximal runs
  # of passing / excluded codepoints and running the full pass chain only on the
  # passing runs (e.g. Malayalam chillu letters, excluded from the source filter,
  # now pass through untouched instead of being decomposed via InterIndic).
  def execute(string, %CompiledTransform{passes: passes, filter: filter}) do
    string
    |> String.to_charlist()
    |> Enum.chunk_by(fn codepoint -> match_codepoint_set?(codepoint, filter) end)
    |> Enum.map_join("", fn [first | _] = chunk ->
      run = List.to_string(chunk)

      if match_codepoint_set?(first, filter) do
        # The run already contains only filter-passing input, so the per-rule
        # filter gate is redundant for the first pass and wrong for later passes
        # (which see already-transliterated, possibly out-of-filter text). Pass
        # nil so every pass runs fully on the selected run, as ICU does.
        execute_passes(passes, run, nil)
      else
        run
      end
    end)
  end

  defp execute_passes([], string, _filter), do: string

  defp execute_passes([pass | rest], string, filter) do
    result = execute_pass(string, pass, filter)

    normalized =
      case pass do
        {:transform, _} ->
          # Normalize to NFC after sub-transform passes so that combining marks
          # produced by one transform are recomposed before the next pass.
          String.normalize(result, :nfc)

        _ ->
          result
      end

    execute_passes(rest, normalized, filter)
  end

  defp execute_pass(string, {:builtin, name}, _filter) do
    Builtin.apply(string, name)
  end

  defp execute_pass(string, {:transform, name}, _filter) do
    case Unicode.Transform.do_transform(string, name, :forward) do
      {:ok, result} -> result
      {:error, _} -> string
    end
  end

  defp execute_pass(string, {:conversions, rules}, filter) do
    apply_conversion_rules(string, rules, filter)
  end

  # Maximum iterations to prevent infinite loops in pathological rules
  @max_iterations 100_000

  # Apply a set of conversion rules to a string using cursor-based matching.
  defp apply_conversion_rules(string, rules, filter) do
    do_apply_rules(string, 0, rules, filter, @max_iterations)
  end

  # Main cursor loop - works with byte positions in the binary
  defp do_apply_rules(string, cursor, _rules, _filter, _limit) when cursor >= byte_size(string) do
    string
  end

  defp do_apply_rules(string, _cursor, _rules, _filter, limit) when limit <= 0 do
    string
  end

  defp do_apply_rules(string, cursor, rules, filter, limit) do
    before = binary_part(string, 0, cursor)
    remaining = binary_part(string, cursor, byte_size(string) - cursor)

    case try_rules(rules, before, remaining, filter) do
      {:match, replacement, revisit_text, rest_text} ->
        new_string = before <> replacement <> revisit_text <> rest_text
        new_cursor = byte_size(before) + byte_size(replacement)

        # Guard against infinite loop: if nothing was consumed or inserted,
        # advance by one codepoint
        if new_cursor == cursor && new_string == string do
          new_cursor = cursor + codepoint_byte_size(remaining)
          do_apply_rules(string, new_cursor, rules, filter, limit - 1)
        else
          do_apply_rules(new_string, new_cursor, rules, filter, limit - 1)
        end

      :no_match ->
        <<_::utf8, _rest::binary>> = remaining
        new_cursor = cursor + codepoint_byte_size(remaining)
        do_apply_rules(string, new_cursor, rules, filter, limit - 1)
    end
  end

  defp codepoint_byte_size(<<_::utf8, rest::binary>> = string) do
    byte_size(string) - byte_size(rest)
  end

  # Try each rule in order at the current position
  defp try_rules([], _before, _remaining, _filter), do: :no_match

  defp try_rules([rule | rest], before, remaining, filter) do
    case try_rule(rule, before, remaining, filter) do
      {:match, _, _, _} = match -> match
      :no_match -> try_rules(rest, before, remaining, filter)
    end
  end

  # Try to match a single rule at the current position.
  #
  # Captures from the before-context, the key pattern and the after-context are
  # concatenated left-to-right so numbered backreferences (`$1`, `$2`, ...) in the
  # replacement resolve against groups anywhere in the rule, as ICU numbers them.
  defp try_rule(rule, before, remaining, filter) do
    {start_anchored?, before_context, pattern} = resolve_start_anchor(rule)

    with true <- check_filter(remaining, filter),
         true <- not start_anchored? or before == "",
         {:ok, before_caps} <- check_before_context(before, before_context),
         {:ok, _matched, key_caps, rest} <- match_pattern(remaining, pattern),
         {:ok, after_caps} <- check_after_context(rest, rule.after_context) do
      captures = before_caps ++ key_caps ++ after_caps
      replacement = resolve_replacement(rule.replacement, captures)
      revisit = resolve_replacement(rule.revisit || "", captures)
      {:match, replacement, revisit, rest}
    else
      _ -> :no_match
    end
  end

  # ICU's `^` start-of-text anchor: a `^` before-context, or a key pattern that
  # begins with `^`, matches only at the start of the text being transformed in
  # this pass (mirroring `$` for end-of-text). We surface that as a flag plus the
  # anchor-free before-context/pattern; `try_rule` then requires `before == ""`.
  defp resolve_start_anchor(rule) do
    cond do
      is_binary(rule.before_context) and String.trim(rule.before_context) == "^" ->
        {true, nil, rule.pattern}

      is_binary(rule.pattern) and String.starts_with?(rule.pattern, "^") ->
        stripped =
          rule.pattern |> binary_part(1, byte_size(rule.pattern) - 1) |> String.trim_leading()

        {true, rule.before_context, if(stripped == "", do: nil, else: stripped)}

      true ->
        {false, rule.before_context, rule.pattern}
    end
  end

  # The global filter is enforced as a top-level run partition in execute/2 (each
  # pass runs only on an already filter-passing run), so the per-rule filter is
  # always disabled here and this check is a no-op.
  defp check_filter(_remaining, _filter), do: true

  # Check before context. Returns `{:ok, captures}` (the captured groups, for
  # backreferences) on a match, or `:no_match`.
  defp check_before_context(_before, nil), do: {:ok, []}

  defp check_before_context(before, context) do
    regex = get_or_compile_regex(translate_context_anchors(context), :suffix)
    # Prepend the start-of-text boundary sentinel. The context regex is
    # suffix-anchored (`(?:...)\z`), so the sentinel only participates when the
    # context runs off the start edge (e.g. a `$`-anchored context followed by a
    # real character); mid-string matches are unaffected.
    subject = @boundary_padding <> before

    case Regex.run(regex, subject, capture: :all) do
      [_matched | captures] -> {:ok, captures}
      nil -> :no_match
    end
  end

  # Check after context. Returns `{:ok, captures}` on a match, or `:no_match`.
  defp check_after_context(_after, nil), do: {:ok, []}

  defp check_after_context(after_text, context) do
    regex = get_or_compile_regex(translate_context_anchors(context), :prefix)
    # Append the end-of-text boundary sentinel. The context regex is
    # prefix-anchored (`\A(?:...)`), so the sentinel only participates when the
    # context runs off the end edge; mid-string matches are unaffected.
    subject = after_text <> @boundary_sentinel

    case Regex.run(regex, subject, capture: :all) do
      [_matched | captures] -> {:ok, captures}
      nil -> :no_match
    end
  end

  # Translate the ICU boundary anchor `$` in a context pattern to the boundary
  # sentinel. In CLDR rules `$` in a context is the start/end-of-text anchor, so a
  # negated set like `[^.$]` must *exclude* the text boundary (and a bare `$` must
  # match *only* at the boundary). Variables have already been substituted by the
  # time contexts reach the engine, so any remaining unescaped `$` is an anchor.
  defp translate_context_anchors(context) do
    if String.contains?(context, "$") do
      Regex.replace(~r/(?<!\\)\$/u, context, @boundary_sentinel)
    else
      context
    end
  end

  # Match a pattern at the beginning of the string.
  # Returns {:ok, matched_text, captures, rest} or :no_match
  # Nil pattern matches zero-length text (context-only rules that insert text).
  # These are used for insertion rules where context determines the insertion point.
  defp match_pattern("", nil), do: :no_match

  defp match_pattern(text, nil) do
    {:ok, "", [], text}
  end

  defp match_pattern(text, pattern) when is_binary(pattern) do
    if has_regex_features?(pattern) do
      match_regex_pattern(text, pattern)
    else
      match_literal_pattern(text, pattern)
    end
  end

  defp match_literal_pattern(text, pattern) do
    literal = unescape_pattern(pattern)
    byte_len = byte_size(literal)

    if byte_len > 0 && byte_len <= byte_size(text) &&
         binary_part(text, 0, byte_len) == literal do
      rest = binary_part(text, byte_len, byte_size(text) - byte_len)
      {:ok, literal, [], rest}
    else
      :no_match
    end
  end

  defp match_regex_pattern(text, pattern) do
    regex = get_or_compile_regex(pattern, :prefix)

    case Regex.run(regex, text, capture: :all) do
      [matched | captures] when matched != "" ->
        byte_len = byte_size(matched)
        rest = binary_part(text, byte_len, byte_size(text) - byte_len)
        {:ok, matched, captures, rest}

      _ ->
        :no_match
    end
  end

  # Check if a pattern contains regex-like features
  defp has_regex_features?(pattern) do
    String.contains?(pattern, "[") ||
      String.contains?(pattern, "(") ||
      String.contains?(pattern, "+") ||
      String.contains?(pattern, "*") ||
      String.contains?(pattern, "\\p{")
  end

  # Resolve replacement text, handling backreferences ($1, $2, etc.)
  # and function calls (&FunctionName($1))
  defp resolve_replacement(replacement, captures) when is_binary(replacement) do
    resolved =
      if String.contains?(replacement, "$") && captures != [] do
        Pattern.apply_backreferences(replacement, captures)
      else
        replacement
      end

    if String.contains?(resolved, "&") do
      resolve_function_calls(resolved)
    else
      resolved
    end
  end

  # Resolve &FunctionName(arg) calls in replacement text.
  # After backreference substitution, function calls look like &Any-Upper(x)
  # where x is the resolved text from captures.
  defp resolve_function_calls(text) do
    do_resolve_functions(text, "")
  end

  defp do_resolve_functions("", acc), do: acc

  defp do_resolve_functions(<<"&", rest::binary>>, acc) do
    case extract_function_call(rest) do
      {:ok, func_name, arg, remainder} ->
        result = apply_function_call(func_name, arg)
        do_resolve_functions(remainder, acc <> result)

      :not_a_function ->
        do_resolve_functions(rest, acc <> "&")
    end
  end

  defp do_resolve_functions(<<char::utf8, rest::binary>>, acc) do
    do_resolve_functions(rest, acc <> <<char::utf8>>)
  end

  # Extract function name and argument from &FuncName(arg)
  # Returns {:ok, name, arg, rest} or :not_a_function
  defp extract_function_call(text) do
    case Regex.run(~r/\A([A-Za-z][A-Za-z0-9_-]*)\(/, text) do
      [prefix, func_name] ->
        rest_after_paren =
          binary_part(text, byte_size(prefix), byte_size(text) - byte_size(prefix))

        case extract_function_arg(rest_after_paren, 1, "") do
          {:ok, arg, remainder} -> {:ok, func_name, arg, remainder}
          :error -> :not_a_function
        end

      _ ->
        :not_a_function
    end
  end

  # Extract the argument from inside parentheses, handling nested parens
  defp extract_function_arg("", _depth, _acc), do: :error

  defp extract_function_arg(<<"(", rest::binary>>, depth, acc) do
    extract_function_arg(rest, depth + 1, acc <> "(")
  end

  defp extract_function_arg(<<")", rest::binary>>, 1, acc) do
    {:ok, acc, rest}
  end

  defp extract_function_arg(<<")", rest::binary>>, depth, acc) do
    extract_function_arg(rest, depth - 1, acc <> ")")
  end

  defp extract_function_arg(<<char::utf8, rest::binary>>, depth, acc) do
    extract_function_arg(rest, depth, acc <> <<char::utf8>>)
  end

  # Apply a function call to its argument
  defp apply_function_call(func_name, arg) do
    if Builtin.builtin?(func_name) do
      Builtin.apply(arg, func_name)
    else
      # Try as a transform name
      case Unicode.Transform.do_transform(arg, func_name, :forward) do
        {:ok, result} -> result
        {:error, _} -> "&" <> func_name <> "(" <> arg <> ")"
      end
    end
  end

  # Check if a codepoint matches a Unicode set
  defp match_codepoint_set?(codepoint, unicode_set) do
    regex = get_or_compile_regex(unicode_set, :full)
    Regex.match?(regex, <<codepoint::utf8>>)
  end

  # Get or compile a regex from a pattern, using a cache
  defp get_or_compile_regex(pattern, mode) do
    cache_key = {pattern, mode}
    ensure_regex_cache()

    case :ets.lookup(@regex_cache_table, cache_key) do
      [{^cache_key, regex}] ->
        regex

      [] ->
        regex = compile_regex(pattern, mode)
        :ets.insert(@regex_cache_table, {cache_key, regex})
        regex
    end
  rescue
    ArgumentError ->
      compile_regex(pattern, mode)
  end

  defp compile_regex(pattern, mode) do
    regex_source = Pattern.to_regex_source(pattern)

    regex_str =
      case mode do
        :prefix -> "\\A(?:" <> regex_source <> ")"
        :suffix -> "(?:" <> regex_source <> ")\\z"
        :full -> "\\A(?:" <> regex_source <> ")\\z"
      end

    case Regex.compile(regex_str, "u") do
      {:ok, regex} ->
        regex

      {:error, _} ->
        # Fall back to treating pattern as literal
        escaped = Regex.escape(unescape_pattern(pattern))

        fallback_str =
          case mode do
            :prefix -> "\\A(?:" <> escaped <> ")"
            :suffix -> "(?:" <> escaped <> ")\\z"
            :full -> "\\A(?:" <> escaped <> ")\\z"
          end

        Regex.compile!(fallback_str, "u")
    end
  end

  defp ensure_regex_cache do
    case :ets.whereis(@regex_cache_table) do
      :undefined ->
        :ets.new(@regex_cache_table, [:named_table, :set, :public, read_concurrency: true])

      _ ->
        :ok
    end
  end

  defp unescape_pattern(pattern) do
    do_unescape(pattern, "")
  end

  defp do_unescape("", acc), do: acc

  defp do_unescape(<<"\\u", hex::binary-4, rest::binary>>, acc) do
    codepoint = String.to_integer(hex, 16)
    do_unescape(rest, acc <> <<codepoint::utf8>>)
  end

  defp do_unescape(<<"\\U", hex::binary-8, rest::binary>>, acc) do
    codepoint = String.to_integer(hex, 16)
    do_unescape(rest, acc <> <<codepoint::utf8>>)
  end

  defp do_unescape(<<"\\", char::utf8, rest::binary>>, acc) do
    do_unescape(rest, acc <> <<char::utf8>>)
  end

  defp do_unescape(<<"'", rest::binary>>, acc) do
    {quoted, remainder} = extract_quoted(rest)
    do_unescape(remainder, acc <> quoted)
  end

  # Unquoted spaces in a literal source pattern are syntactic separators, not
  # part of the text to match (a literal space is written `\ ` or `' '`). Without
  # this, a rule like `t ͡ → t` would try to match "t<space><tie>" and never fire —
  # e.g. the affricate rules in the Japanese transliterations.
  defp do_unescape(<<" ", rest::binary>>, acc) do
    do_unescape(rest, acc)
  end

  defp do_unescape(<<char::utf8, rest::binary>>, acc) do
    do_unescape(rest, acc <> <<char::utf8>>)
  end

  defp extract_quoted(string, acc \\ "")
  defp extract_quoted("", acc), do: {acc, ""}
  defp extract_quoted(<<"'", rest::binary>>, acc), do: {acc, rest}

  defp extract_quoted(<<char::utf8, rest::binary>>, acc) do
    extract_quoted(rest, acc <> <<char::utf8>>)
  end
end

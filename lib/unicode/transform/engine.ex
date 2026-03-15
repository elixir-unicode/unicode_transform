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

  alias Unicode.Transform.Compiler.CompiledTransform
  alias Unicode.Transform.{Builtin, Pattern}

  # Cache compiled regexes to avoid recompiling on every match attempt
  @regex_cache_table :unicode_transform_regex_cache

  @doc """
  Executes a compiled transform on a string.

  ### Arguments

  * `string` — the input string.

  * `compiled` — a `CompiledTransform` struct.

  ### Returns

  The transformed string.

  """
  @spec execute(String.t(), CompiledTransform.t()) :: String.t()
  def execute(string, %CompiledTransform{passes: passes, filter: filter}) do
    Enum.reduce(passes, string, fn pass, acc ->
      execute_pass(acc, pass, filter)
    end)
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

  # Try to match a single rule at the current position
  defp try_rule(rule, before, remaining, filter) do
    with true <- check_filter(remaining, filter),
         true <- check_before_context(before, rule.before_context),
         {:ok, _matched, captures, rest} <- match_pattern(remaining, rule.pattern),
         true <- check_after_context(rest, rule.after_context) do
      replacement = resolve_replacement(rule.replacement, captures)
      revisit = resolve_replacement(rule.revisit || "", captures)
      {:match, replacement, revisit, rest}
    else
      _ -> :no_match
    end
  end

  # Check if the first codepoint passes the global filter
  defp check_filter(_remaining, nil), do: true

  defp check_filter(<<cp::utf8, _rest::binary>>, unicode_set) do
    match_codepoint_set?(cp, unicode_set)
  end

  defp check_filter("", _), do: false

  # Check before context
  defp check_before_context(_before, nil), do: true

  defp check_before_context(before, context) do
    regex = get_or_compile_regex(context, :suffix)
    Regex.match?(regex, before)
  end

  # Check after context
  defp check_after_context(_after, nil), do: true

  defp check_after_context(after_text, context) do
    regex = get_or_compile_regex(context, :prefix)
    Regex.match?(regex, after_text)
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
  defp resolve_replacement(replacement, captures) when is_binary(replacement) do
    if String.contains?(replacement, "$") && captures != [] do
      Pattern.apply_backreferences(replacement, captures)
    else
      replacement
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

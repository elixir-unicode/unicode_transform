defmodule Unicode.Transform.Pattern do
  @moduledoc """
  Compiles CLDR transform rule patterns into Elixir regexes.

  Transform patterns can contain:

  * Literal characters.

  * Unicode set notation: `[:Mn:]`, `[[:Latin:][0-9]]`.

  * Quantifiers: `+`, `*`, `?`.

  * Capture groups: `(...)` for backreferences.

  * Escaped characters: `\\:`, `\\u0041`.

  * Quoted literals: `'text'`.

  """

  @doc """
  Compiles a pattern string into a regex.

  ### Arguments

  * `pattern` — the pattern string from a CLDR rule.

  ### Returns

  `{:ok, regex}` or `{:error, reason}`.

  """
  @spec compile(String.t()) :: {:ok, Regex.t()} | {:error, term()}
  def compile(pattern) do
    try do
      regex_source = to_regex_source(pattern)
      Regex.compile(regex_source, "u")
    rescue
      e -> {:error, Exception.message(e)}
    end
  end

  @doc """
  Converts a pattern to a regex source string.

  ### Arguments

  * `pattern` — the pattern string.

  ### Returns

  A regex source string.

  """
  @spec to_regex_source(String.t()) :: String.t()
  def to_regex_source(pattern) do
    pattern
    |> tokenize()
    |> tokens_to_regex()
  end

  # Tokenize a pattern into a list of tokens
  defp tokenize(pattern) do
    do_tokenize(pattern, [])
    |> Enum.reverse()
  end

  defp do_tokenize("", acc), do: acc

  # Escape sequences
  defp do_tokenize(<<"\\u", hex::binary-4, rest::binary>>, acc) do
    codepoint = String.to_integer(hex, 16)
    do_tokenize(rest, [{:literal, <<codepoint::utf8>>} | acc])
  end

  defp do_tokenize(<<"\\U", hex::binary-8, rest::binary>>, acc) do
    codepoint = String.to_integer(hex, 16)
    do_tokenize(rest, [{:literal, <<codepoint::utf8>>} | acc])
  end

  defp do_tokenize(<<"\\", char::utf8, rest::binary>>, acc) do
    do_tokenize(rest, [{:literal, <<char::utf8>>} | acc])
  end

  # Quoted string
  defp do_tokenize(<<"'", rest::binary>>, acc) do
    {quoted, remainder} = extract_quoted(rest)
    do_tokenize(remainder, [{:literal, quoted} | acc])
  end

  # Unicode set (character class)
  defp do_tokenize(<<"[", rest::binary>>, acc) do
    {class_content, remainder} = extract_character_class(rest, 1)
    unicode_set = "[" <> class_content
    do_tokenize(remainder, [{:unicode_set, unicode_set} | acc])
  end

  # Capture group
  defp do_tokenize(<<"(", rest::binary>>, acc) do
    do_tokenize(rest, [{:group_open} | acc])
  end

  defp do_tokenize(<<")", rest::binary>>, acc) do
    do_tokenize(rest, [{:group_close} | acc])
  end

  # Quantifiers
  defp do_tokenize(<<"+", rest::binary>>, acc) do
    do_tokenize(rest, [{:quantifier, "+"} | acc])
  end

  defp do_tokenize(<<"*", rest::binary>>, acc) do
    do_tokenize(rest, [{:quantifier, "*"} | acc])
  end

  defp do_tokenize(<<"?", rest::binary>>, acc) do
    do_tokenize(rest, [{:quantifier, "?"} | acc])
  end

  # Backreference in replacement
  defp do_tokenize(<<"$", d, rest::binary>>, acc) when d in ?0..?9 do
    {digits, remainder} = extract_digits(<<d, rest::binary>>)
    do_tokenize(remainder, [{:backref, String.to_integer(digits)} | acc])
  end

  # Dot — wildcard matching any single character
  defp do_tokenize(<<".", rest::binary>>, acc) do
    do_tokenize(rest, [{:wildcard} | acc])
  end

  # Spaces — generally syntactic in patterns, skip them
  defp do_tokenize(<<" ", rest::binary>>, acc) do
    do_tokenize(rest, acc)
  end

  # Regular character — literal
  defp do_tokenize(<<char::utf8, rest::binary>>, acc) do
    do_tokenize(rest, [{:literal, <<char::utf8>>} | acc])
  end

  # Convert token list to regex source
  defp tokens_to_regex(tokens) do
    tokens
    |> Enum.map(&token_to_regex/1)
    |> Enum.join()
  end

  defp token_to_regex({:literal, text}) do
    Regex.escape(text)
  end

  defp token_to_regex({:unicode_set, set}) do
    # In ICU's UnicodeSet syntax, unquoted/unescaped whitespace inside [...]
    # is purely syntactic (for readability) and should be ignored.
    # Strip such whitespace before regex compilation.
    cleaned_set = strip_set_whitespace(set)

    case Unicode.Regex.compile(cleaned_set, "u") do
      {:ok, regex} -> Regex.source(regex)
      _ -> Regex.escape(set)
    end
  rescue
    _ -> Regex.escape(set)
  end

  defp token_to_regex({:wildcard}), do: "."
  defp token_to_regex({:group_open}), do: "("
  defp token_to_regex({:group_close}), do: ")"
  defp token_to_regex({:quantifier, q}), do: q
  defp token_to_regex({:backref, n}), do: "\\#{n}"

  # Strip unquoted, unescaped whitespace from a Unicode set string.
  # In ICU's UnicodeSet syntax, unquoted whitespace inside [...] is
  # purely syntactic and ignored. Escaped spaces (\ ) are preserved.
  # Note: inside character classes, ' is a literal character (not a
  # quote delimiter), so we don't treat it specially here.
  defp strip_set_whitespace(set) do
    do_strip_set_ws(set, "")
  end

  defp do_strip_set_ws("", acc), do: acc

  defp do_strip_set_ws(<<"\\", char::utf8, rest::binary>>, acc) do
    do_strip_set_ws(rest, acc <> "\\" <> <<char::utf8>>)
  end

  defp do_strip_set_ws(<<" ", rest::binary>>, acc) do
    do_strip_set_ws(rest, acc)
  end

  defp do_strip_set_ws(<<"\t", rest::binary>>, acc) do
    do_strip_set_ws(rest, acc)
  end

  defp do_strip_set_ws(<<char::utf8, rest::binary>>, acc) do
    do_strip_set_ws(rest, acc <> <<char::utf8>>)
  end

  @doc """
  Applies backreference substitution in a replacement string.

  ### Arguments

  * `replacement` — the replacement string (may contain `$1`, `$2`, etc.).

  * `captures` — list of captured groups from the match.

  ### Returns

  The replacement string with backreferences resolved.

  """
  @spec apply_backreferences(String.t(), [String.t()]) :: String.t()
  def apply_backreferences(replacement, captures) do
    do_apply_backrefs(replacement, captures, "")
  end

  defp do_apply_backrefs("", _captures, acc), do: acc

  defp do_apply_backrefs(<<"\\u", hex::binary-4, rest::binary>>, captures, acc) do
    codepoint = String.to_integer(hex, 16)
    do_apply_backrefs(rest, captures, acc <> <<codepoint::utf8>>)
  end

  defp do_apply_backrefs(<<"\\", char::utf8, rest::binary>>, captures, acc) do
    do_apply_backrefs(rest, captures, acc <> <<char::utf8>>)
  end

  defp do_apply_backrefs(<<"'", rest::binary>>, captures, acc) do
    {quoted, remainder} = extract_quoted(rest)
    do_apply_backrefs(remainder, captures, acc <> quoted)
  end

  defp do_apply_backrefs(<<"$", rest::binary>>, captures, acc) do
    {digits, remainder} = extract_digits(rest)

    if digits != "" do
      index = String.to_integer(digits)
      replacement = Enum.at(captures, index - 1, "")
      do_apply_backrefs(remainder, captures, acc <> replacement)
    else
      do_apply_backrefs(rest, captures, acc <> "$")
    end
  end

  defp do_apply_backrefs(<<" ", rest::binary>>, captures, acc) do
    # Skip spaces in replacement (syntactic separators)
    do_apply_backrefs(rest, captures, acc)
  end

  defp do_apply_backrefs(<<char::utf8, rest::binary>>, captures, acc) do
    do_apply_backrefs(rest, captures, acc <> <<char::utf8>>)
  end

  # Extract digits
  defp extract_digits(string, acc \\ "")
  defp extract_digits("", acc), do: {acc, ""}

  defp extract_digits(<<d, rest::binary>>, acc) when d in ?0..?9 do
    extract_digits(rest, acc <> <<d>>)
  end

  defp extract_digits(rest, acc), do: {acc, rest}

  # Extract quoted string
  defp extract_quoted(string, acc \\ "")
  defp extract_quoted("", acc), do: {acc, ""}
  defp extract_quoted(<<"'", rest::binary>>, acc), do: {acc, rest}

  defp extract_quoted(<<char::utf8, rest::binary>>, acc) do
    extract_quoted(rest, acc <> <<char::utf8>>)
  end

  # Extract character class content
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
end

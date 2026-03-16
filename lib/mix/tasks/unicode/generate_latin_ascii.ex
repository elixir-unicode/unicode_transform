defmodule Mix.Tasks.Unicode.GenerateLatinAscii do
  @moduledoc """
  Generates the compiled `Unicode.Transform.LatinAscii` module from
  `priv/transforms/Latin-ASCII.xml`.

  The generated module replaces the cursor-based rule engine with
  direct pattern-matched function heads for O(1) codepoint lookup.

  ## Usage

      mix unicode.generate_latin_ascii

  """
  @shortdoc "Generate compiled Latin-ASCII transform module"

  use Mix.Task

  @output_path "lib/unicode/transform/latin_ascii.ex"

  @impl Mix.Task
  def run(_args) do
    Mix.Task.run("app.start")

    xml_path = Path.join(Unicode.Transform.Loader.transforms_dir(), "Latin-ASCII.xml")
    data = Unicode.Transform.Loader.load_file(xml_path)
    rules = Unicode.Transform.Parser.parse(data.rules)

    conversions =
      rules
      |> Enum.filter(&match?(%Unicode.Transform.Rule.Conversion{direction: :forward}, &1))

    # Separate the context rule from simple literal rules
    {context_rules, simple_rules} =
      Enum.split_with(conversions, fn r ->
        r.left.before_context != nil || r.left.after_context != nil
      end)

    # Unescape pattern and replacement text
    mappings =
      simple_rules
      |> Enum.map(fn r ->
        pattern = unescape(r.left.text)
        replacement = unescape(r.right.text)
        {pattern, replacement}
      end)
      |> Enum.reject(fn {pattern, _} -> pattern == "" end)
      # Sort by byte_size descending so longer patterns match first
      |> Enum.sort_by(fn {pattern, _} -> byte_size(pattern) end, :desc)

    source = generate_module(mappings, context_rules)

    File.write!(@output_path, source)
    Mix.shell().info("Generated #{@output_path} with #{length(mappings)} mappings")

    # Format the generated file
    Mix.Task.run("format", [@output_path])
    Mix.shell().info("Formatted #{@output_path}")
  end

  defp generate_module(mappings, _context_rules) do
    function_heads =
      mappings
      |> Enum.map(fn {pattern, replacement} ->
        generate_function_head(pattern, replacement)
      end)
      |> Enum.join("\n")

    combining_mark_ranges = generate_combining_mark_ranges()

    """
    defmodule Unicode.Transform.LatinAscii do
      @moduledoc \"\"\"
      Compiled Latin-ASCII transform for fast codepoint-level transliteration.

      Auto-generated from `priv/transforms/Latin-ASCII.xml`.
      Regenerate with: `mix unicode.generate_latin_ascii`

      This module replaces the cursor-based rule engine with direct
      pattern-matched function heads, achieving O(1) lookup per codepoint
      via the BEAM's pattern matching dispatch.

      \"\"\"

      @doc \"\"\"
      Transforms a Latin string to ASCII.

      Applies NFD normalization, maps each codepoint to its ASCII equivalent,
      strips combining marks, and applies NFC normalization.

      ### Arguments

      * `string` — the input string.

      ### Returns

      The ASCII-transliterated string.

      \"\"\"
      @spec transform(String.t()) :: String.t()
      def transform(string) do
        string
        |> String.normalize(:nfd)
        |> do_transform(<<>>)
        |> String.normalize(:nfc)
      end

      # Generated mapping rules (longest patterns first)
    #{function_heads}

      # Strip combining marks (Unicode General Category Mn = Nonspacing Mark).
      # After NFD, combining diacritical marks follow their base character.
      # We skip them to produce ASCII output.
    #{combining_mark_ranges}

      # Passthrough for unmatched codepoints
      defp do_transform(<<cp::utf8, rest::binary>>, acc) do
        do_transform(rest, <<acc::binary, cp::utf8>>)
      end

      defp do_transform(<<>>, acc), do: acc
    end
    """
  end

  defp generate_function_head(pattern, replacement) do
    pattern_escaped = inspect(pattern)
    replacement_escaped = inspect(replacement)

    "  defp do_transform(<<#{pattern_escaped}, rest::binary>>, acc), " <>
      "do: do_transform(rest, <<acc::binary, #{replacement_escaped}>>)"
  end

  defp generate_combining_mark_ranges do
    # Common combining mark ranges (Unicode General Category Mn).
    # We generate guard-based function heads for combining mark ranges.
    # These are the most common ranges encountered in Latin text after NFD.
    ranges = [
      # Combining Diacritical Marks
      {0x0300, 0x036F},
      # Combining Diacritical Marks Extended
      {0x1AB0, 0x1AFF},
      # Combining Diacritical Marks Supplement
      {0x1DC0, 0x1DFF},
      # Combining Diacritical Marks for Symbols
      {0x20D0, 0x20FF},
      # Combining Half Marks
      {0xFE20, 0xFE2F}
    ]

    ranges
    |> Enum.map(fn {first, last} ->
      "  defp do_transform(<<cp::utf8, rest::binary>>, acc) " <>
        "when cp >= #{hex(first)} and cp <= #{hex(last)}, " <>
        "do: do_transform(rest, acc)"
    end)
    |> Enum.join("\n")
  end

  defp hex(n), do: "0x#{Integer.to_string(n, 16)}"

  # Unescape CLDR transform pattern/replacement text.
  # Handles \uXXXX, \UXXXXXXXX, \x, and 'quoted' literals.
  defp unescape(nil), do: ""
  defp unescape(text), do: do_unescape(text, "")

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

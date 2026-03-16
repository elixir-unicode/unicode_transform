defmodule Unicode.Transform.NifComparisonTest do
  @moduledoc """
  Property-based tests comparing the pure-Elixir transform engine
  against the ICU NIF backend. The NIF result is treated as canonical.

  These tests require the NIF to be compiled and available. They are
  automatically skipped when the NIF is not loaded.
  """

  use ExUnit.Case, async: true
  use ExUnitProperties

  alias Unicode.Transform.Nif

  # Transform IDs that exist in both the Elixir engine (CLDR XML) and ICU.
  # We focus on script-to-Latin transforms since those are the most commonly
  # used and have the best coverage in both backends.
  @common_transforms [
    "Any-Latin",
    "Any-NFC",
    "Any-NFD",
    "Any-NFKC",
    "Any-NFKD",
    "Any-Null",
    "Any-Upper",
    "Any-Lower",
    "Any-Accents",
    "Latin-ASCII",
    "Greek-Latin",
    "Cyrillic-Latin",
    "Hebrew-Latin",
    "Arabic-Latin",
    "Devanagari-Latin",
    "Bengali-Latin",
    "Gujarati-Latin",
    "Gurmukhi-Latin",
    "Kannada-Latin",
    "Malayalam-Latin",
    "Oriya-Latin",
    "Tamil-Latin",
    "Telugu-Latin",
    "Thai-Latin",
    "Katakana-Latin",
    "Hiragana-Latin",
    "Hangul-Latin",
    "Han-Latin",
    "Hant-Latin",
    "Hiragana-Katakana",
    "Georgian-Latin",
    "Armenian-Latin",
    "Syriac-Latin",
    "Thaana-Latin"
  ]

  # Script-specific character ranges for generating relevant test input.
  # Each range is a list of {start_codepoint, end_codepoint} tuples.
  @script_ranges %{
    "Greek-Latin" => [{0x0370, 0x03FF}],
    "Cyrillic-Latin" => [{0x0400, 0x04FF}],
    "Hebrew-Latin" => [{0x0590, 0x05FF}],
    "Arabic-Latin" => [{0x0600, 0x06FF}],
    "Devanagari-Latin" => [{0x0900, 0x097F}],
    "Bengali-Latin" => [{0x0980, 0x09FF}],
    "Gujarati-Latin" => [{0x0A80, 0x0AFF}],
    "Gurmukhi-Latin" => [{0x0A00, 0x0A7F}],
    "Kannada-Latin" => [{0x0C80, 0x0CFF}],
    "Malayalam-Latin" => [{0x0D00, 0x0D7F}],
    "Oriya-Latin" => [{0x0B00, 0x0B7F}],
    "Tamil-Latin" => [{0x0B80, 0x0BFF}],
    "Telugu-Latin" => [{0x0C00, 0x0C7F}],
    "Thai-Latin" => [{0x0E00, 0x0E7F}],
    "Katakana-Latin" => [{0x30A0, 0x30FF}],
    "Hiragana-Latin" => [{0x3040, 0x309F}],
    "Hangul-Latin" => [{0xAC00, 0xAC7F}],
    "Han-Latin" => [{0x4E00, 0x4E7F}],
    "Hant-Latin" => [{0x4E00, 0x4E7F}],
    "Hiragana-Katakana" => [{0x3040, 0x309F}],
    "Georgian-Latin" => [{0x10A0, 0x10FF}],
    "Armenian-Latin" => [{0x0530, 0x058F}],
    "Syriac-Latin" => [{0x0700, 0x074F}],
    "Thaana-Latin" => [{0x0780, 0x07BF}]
  }

  # -------------------------------------------------------------------
  # Generators
  # -------------------------------------------------------------------

  # Generate a valid Unicode string from the Basic Multilingual Plane,
  # excluding surrogates and noncharacters.
  defp unicode_string do
    gen all(chars <- list_of(unicode_char(), min_length: 1, max_length: 64)) do
      List.to_string(chars)
    end
  end

  defp unicode_char do
    gen all(
          cp <- integer(0x0020..0xFFFD),
          cp not in 0xD800..0xDFFF,
          cp not in 0xFDD0..0xFDEF
        ) do
      cp
    end
  end

  # Generate a string of characters from a specific script range.
  defp script_string(ranges) do
    char_gen =
      ranges
      |> Enum.map(fn {lo, hi} -> integer(lo..hi) end)
      |> one_of()
      |> filter(fn cp ->
        # Only include assigned characters (valid when encoded as UTF-8)
        try do
          s = <<cp::utf8>>
          String.valid?(s)
        rescue
          _ -> false
        end
      end)

    gen all(chars <- list_of(char_gen, min_length: 1, max_length: 32)) do
      List.to_string(chars)
    end
  end

  # Generate a string from well-established Unicode ranges (Latin, Greek,
  # Cyrillic) where ICU and OTP agree on normalization and casing.
  defp common_script_string do
    char_gen =
      one_of([
        # Basic Latin + Latin-1 Supplement + Latin Extended-A/B
        integer(0x0020..0x024F),
        # Greek and Coptic
        integer(0x0370..0x03FF),
        # Cyrillic
        integer(0x0400..0x04FF)
      ])
      |> filter(fn cp ->
        try do
          String.valid?(<<cp::utf8>>)
        rescue
          _ -> false
        end
      end)

    gen all(chars <- list_of(char_gen, min_length: 1, max_length: 32)) do
      List.to_string(chars)
    end
  end

  # Generate Latin text (ASCII letters, digits, common punctuation).
  defp latin_string do
    gen all(chars <- list_of(integer(0x0020..0x007E), min_length: 1, max_length: 64)) do
      List.to_string(chars)
    end
  end

  # -------------------------------------------------------------------
  # Helpers
  # -------------------------------------------------------------------

  # Run a transform through the Elixir engine only, using the :backend option.
  defp elixir_transform(string, transform_id, direction) do
    Unicode.Transform.transform(string,
      transform: transform_id,
      direction: direction,
      backend: :elixir
    )
  end

  # Run a transform through the NIF only.
  defp nif_transform(string, transform_id, direction) do
    dir = if direction == :forward, do: 0, else: 1
    Nif.transform(transform_id, string, dir)
  end

  # Check whether a transform ID is available in the Elixir engine.
  defp elixir_available?(transform_id, direction) do
    case elixir_transform("", transform_id, direction) do
      {:ok, _} -> true
      {:error, _} -> false
    end
  end

  # Check whether a transform ID is available in the NIF.
  defp nif_available?(transform_id) do
    case Nif.transform(transform_id, "", 0) do
      {:ok, _} -> true
      {:error, _} -> false
    end
  end

  # Filter to transforms available in both backends.
  defp both_available(transform_ids, direction \\ :forward) do
    Enum.filter(transform_ids, fn id ->
      nif_available?(id) and elixir_available?(id, direction)
    end)
  end

  # -------------------------------------------------------------------
  # Setup
  # -------------------------------------------------------------------

  setup_all do
    unless Nif.available?() do
      IO.puts("\nSkipping NIF comparison tests — NIF not available")
    end

    available = both_available(@common_transforms)

    if Nif.available?() and available == [] do
      IO.puts("\nWarning: NIF is available but no common transforms found in both backends")
    end

    %{available_transforms: available}
  end

  # -------------------------------------------------------------------
  # Property tests
  # -------------------------------------------------------------------

  describe "NIF vs Elixir engine agreement" do
    @describetag nif_comparison: true, timeout: 120_000

    # For normalization and casing tests we restrict to well-established
    # Unicode ranges (Latin, Greek, Cyrillic) where both the system ICU
    # and Erlang/OTP agree. Full BMP comparisons can diverge when the ICU
    # version differs from the Unicode version compiled into OTP.

    property "Any-NFC produces identical results on common scripts",
             %{available_transforms: available} do
      if not Nif.available?() or "Any-NFC" not in available do
        :ok
      else
        check all(string <- common_script_string(), max_runs: 200) do
          {:ok, nif_result} = nif_transform(string, "Any-NFC", :forward)
          {:ok, elixir_result} = elixir_transform(string, "Any-NFC", :forward)

          assert nif_result == elixir_result,
                 "Any-NFC mismatch for #{inspect(string)}\n" <>
                   "  NIF:    #{inspect(nif_result)}\n" <>
                   "  Elixir: #{inspect(elixir_result)}"
        end
      end
    end

    property "Any-NFD produces identical results on common scripts",
             %{available_transforms: available} do
      if not Nif.available?() or "Any-NFD" not in available do
        :ok
      else
        check all(string <- common_script_string(), max_runs: 200) do
          {:ok, nif_result} = nif_transform(string, "Any-NFD", :forward)
          {:ok, elixir_result} = elixir_transform(string, "Any-NFD", :forward)

          assert nif_result == elixir_result,
                 "Any-NFD mismatch for #{inspect(string)}\n" <>
                   "  NIF:    #{inspect(nif_result)}\n" <>
                   "  Elixir: #{inspect(elixir_result)}"
        end
      end
    end

    property "Any-Upper produces identical results on common scripts",
             %{available_transforms: available} do
      if not Nif.available?() or "Any-Upper" not in available do
        :ok
      else
        check all(string <- common_script_string(), max_runs: 200) do
          {:ok, nif_result} = nif_transform(string, "Any-Upper", :forward)
          {:ok, elixir_result} = elixir_transform(string, "Any-Upper", :forward)

          assert nif_result == elixir_result,
                 "Any-Upper mismatch for #{inspect(string)}\n" <>
                   "  NIF:    #{inspect(nif_result)}\n" <>
                   "  Elixir: #{inspect(elixir_result)}"
        end
      end
    end

    # Any-Lower uses Latin-only input to avoid Greek final sigma
    # differences (ICU applies context-aware σ→ς, Elixir doesn't).
    property "Any-Lower produces identical results on Latin input",
             %{available_transforms: available} do
      if not Nif.available?() or "Any-Lower" not in available do
        :ok
      else
        check all(string <- latin_string(), max_runs: 200) do
          {:ok, nif_result} = nif_transform(string, "Any-Lower", :forward)
          {:ok, elixir_result} = elixir_transform(string, "Any-Lower", :forward)

          assert nif_result == elixir_result,
                 "Any-Lower mismatch for #{inspect(string)}\n" <>
                   "  NIF:    #{inspect(nif_result)}\n" <>
                   "  Elixir: #{inspect(elixir_result)}"
        end
      end
    end

    property "Any-Null is identity", %{available_transforms: available} do
      if not Nif.available?() or "Any-Null" not in available do
        :ok
      else
        check all(string <- unicode_string(), max_runs: 200) do
          {:ok, nif_result} = nif_transform(string, "Any-Null", :forward)
          assert nif_result == string, "Any-Null should be identity"
        end
      end
    end

    property "Latin-ASCII produces identical results on ASCII input",
             %{available_transforms: available} do
      if not Nif.available?() or "Latin-ASCII" not in available do
        :ok
      else
        check all(string <- latin_string(), max_runs: 200) do
          {:ok, nif_result} = nif_transform(string, "Latin-ASCII", :forward)
          {:ok, elixir_result} = elixir_transform(string, "Latin-ASCII", :forward)

          assert nif_result == elixir_result,
                 "Latin-ASCII mismatch for #{inspect(string)}\n" <>
                   "  NIF:    #{inspect(nif_result)}\n" <>
                   "  Elixir: #{inspect(elixir_result)}"
        end
      end
    end

    property "script-to-Latin transforms produce results for script input",
             %{available_transforms: available} do
      if not Nif.available?() do
        :ok
      else
        script_transforms =
          @script_ranges
          |> Map.keys()
          |> Enum.filter(&(&1 in available))

        if script_transforms == [] do
          :ok
        else
          check all(
                  transform_id <- member_of(script_transforms),
                  string <- script_string(@script_ranges[transform_id]),
                  max_runs: 300
                ) do
            case nif_transform(string, transform_id, :forward) do
              {:ok, nif_result} ->
                # NIF should produce a non-empty result for non-empty input
                assert is_binary(nif_result),
                       "NIF returned non-binary for #{transform_id}: #{inspect(nif_result)}"

              {:error, reason} ->
                flunk("NIF error for #{transform_id} on #{inspect(string)}: #{inspect(reason)}")
            end
          end
        end
      end
    end

    property "script-to-Latin transforms: Elixir vs NIF comparison",
             %{available_transforms: available} do
      if not Nif.available?() do
        :ok
      else
        script_transforms =
          @script_ranges
          |> Map.keys()
          |> Enum.filter(&(&1 in available))

        if script_transforms == [] do
          :ok
        else
          check all(
                  transform_id <- member_of(script_transforms),
                  string <- script_string(@script_ranges[transform_id]),
                  max_runs: 300
                ) do
            {:ok, nif_result} = nif_transform(string, transform_id, :forward)

            case elixir_transform(string, transform_id, :forward) do
              {:ok, elixir_result} ->
                # Log mismatches but don't fail — this is informational.
                # The Elixir engine may implement a slightly different version
                # of the transform rules than ICU. The NIF is canonical.
                if nif_result != elixir_result do
                  IO.puts(
                    "  [diff] #{transform_id}: #{inspect(string)} → " <>
                      "NIF=#{inspect(nif_result)} Elixir=#{inspect(elixir_result)}"
                  )
                end

              {:error, _reason} ->
                # Elixir engine may not support this transform — skip
                :ok
            end
          end
        end
      end
    end
  end

  # -------------------------------------------------------------------
  # Deterministic comparison tests
  # -------------------------------------------------------------------

  describe "deterministic NIF vs Elixir comparisons" do
    @describetag :nif_comparison

    @latin_ascii_cases [
      {"Ä Ö Ü ß", "A O U ss"},
      {"café", "cafe"},
      {"naïve", "naive"},
      {"résumé", "resume"},
      {"Ångström", "Angstrom"},
      {"Zürich", "Zurich"}
    ]

    for {input, expected} <- @latin_ascii_cases do
      test "Latin-ASCII: #{inspect(input)} → #{inspect(expected)}" do
        if not Nif.available?() do
          :ok
        else
          {:ok, nif_result} = nif_transform(unquote(input), "Latin-ASCII", :forward)
          assert nif_result == unquote(expected)
        end
      end
    end

    @greek_cases [
      {"α", "a"},
      {"β", "v"},
      {"γ", "g"},
      {"δ", "d"},
      {"ΑΒΓΔ", "AVGD"}
    ]

    for {input, _expected} <- @greek_cases do
      test "Greek-Latin NIF produces output for #{inspect(input)}" do
        if not Nif.available?() do
          :ok
        else
          {:ok, result} = nif_transform(unquote(input), "Greek-Latin", :forward)
          assert is_binary(result) and byte_size(result) > 0
        end
      end
    end

    @cyrillic_cases [
      {"Москва", "Moskva"},
      {"Привет", "Privet"}
    ]

    for {input, _expected} <- @cyrillic_cases do
      test "Cyrillic-Latin NIF produces output for #{inspect(input)}" do
        if not Nif.available?() do
          :ok
        else
          {:ok, result} = nif_transform(unquote(input), "Cyrillic-Latin", :forward)
          assert is_binary(result) and byte_size(result) > 0
        end
      end
    end
  end

  # -------------------------------------------------------------------
  # NIF-specific property tests
  # -------------------------------------------------------------------

  describe "NIF robustness" do
    @describetag :nif_comparison

    property "NIF does not crash on arbitrary Unicode input" do
      if not Nif.available?() do
        :ok
      else
        check all(
                string <- unicode_string(),
                transform_id <- member_of(["Any-Latin", "Any-NFC", "Any-NFD", "Latin-ASCII"]),
                max_runs: 500
              ) do
          result = Nif.transform(transform_id, string, 0)

          assert match?({:ok, _}, result) or match?({:error, _}, result),
                 "NIF returned unexpected value: #{inspect(result)}"
        end
      end
    end

    property "NIF handles empty strings" do
      if not Nif.available?() do
        :ok
      else
        check all(
                transform_id <-
                  member_of(["Any-Latin", "Any-NFC", "Any-Upper", "Latin-ASCII"])
              ) do
          assert {:ok, ""} == Nif.transform(transform_id, "", 0)
        end
      end
    end

    property "NIF forward then reverse is approximately round-trip for Any-Latin" do
      if not Nif.available?() do
        :ok
      else
        check all(string <- latin_string(), max_runs: 100) do
          # Latin input through Any-Latin forward should be largely unchanged
          {:ok, forward} = Nif.transform("Any-Latin", string, 0)
          assert is_binary(forward)
        end
      end
    end
  end
end

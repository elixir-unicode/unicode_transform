defmodule Unicode.Transform.Resolve do
  @moduledoc """
  Resolves transform options and IDs to canonical transform identifiers.

  This module handles the mapping from user-facing options (`:from`, `:to`,
  `:transform`, `:direction`) to the internal transform ID and direction
  used by the engine. It also provides conversions between BCP47 (ISO 15924)
  script codes and Unicode/CLDR script names.

  See the [Transform ID resolution](#module-transform-id-resolution) section
  in `Unicode.Transform` for a full description of the resolution process.

  """

  alias Unicode.Transform.{Builtin, Loader}

  @script_names %{
    # Scripts (full names)
    arabic: "Arabic",
    armenian: "Armenian",
    bengali: "Bengali",
    bopomofo: "Bopomofo",
    canadian_aboriginal: "CanadianAboriginal",
    cyrillic: "Cyrillic",
    devanagari: "Devanagari",
    ethiopic: "Ethiopic",
    georgian: "Georgian",
    greek: "Greek",
    gujarati: "Gujarati",
    gurmukhi: "Gurmukhi",
    han: "Han",
    hangul: "Hangul",
    hant: "Hant",
    hebrew: "Hebrew",
    hiragana: "Hiragana",
    interindic: "InterIndic",
    jamo: "Jamo",
    kannada: "Kannada",
    katakana: "Katakana",
    khmer: "Khmer",
    lao: "Lao",
    latin: "Latin",
    malayalam: "Malayalam",
    myanmar: "Myanmar",
    oriya: "Oriya",
    sinhala: "Sinhala",
    syriac: "Syriac",
    tamil: "Tamil",
    telugu: "Telugu",
    thaana: "Thaana",
    thai: "Thai",

    # BCP47 (ISO 15924) script code atoms
    arab: "Arabic",
    armn: "Armenian",
    beng: "Bengali",
    bopo: "Bopomofo",
    cans: "CanadianAboriginal",
    cyrl: "Cyrillic",
    deva: "Devanagari",
    ethi: "Ethiopic",
    geor: "Georgian",
    grek: "Greek",
    gujr: "Gujarati",
    guru: "Gurmukhi",
    hani: "Han",
    hang: "Hangul",
    hebr: "Hebrew",
    hira: "Hiragana",
    jpan: "Jpan",
    khmr: "Khmer",
    knda: "Kannada",
    laoo: "Lao",
    latn: "Latin",
    mlym: "Malayalam",
    mymr: "Myanmar",
    orya: "Oriya",
    sinh: "Sinhala",
    syrc: "Syriac",
    taml: "Tamil",
    telu: "Telugu",
    thaa: "Thaana",
    hans: "Hans",

    # Targets
    ascii: "ASCII",
    fullwidth: "Fullwidth",
    halfwidth: "Halfwidth",

    # Built-in transforms
    nfc: "NFC",
    nfd: "NFD",
    nfkc: "NFKC",
    nfkd: "NFKD",
    upper: "Upper",
    lower: "Lower",
    title: "Title",
    null: "Null",
    remove: "Remove",
    publishing: "Publishing",
    accents: "Accents",

    # Special
    any: "Any"
  }

  # BCP47 (ISO 15924) script code string -> Unicode script name.
  # Used to resolve transform IDs like "Grek-Latn" to "Greek-Latin".
  @bcp47_script_to_unicode %{
    "Arab" => "Arabic",
    "Armn" => "Armenian",
    "Beng" => "Bengali",
    "Bopo" => "Bopomofo",
    "Cans" => "CanadianAboriginal",
    "Cyrl" => "Cyrillic",
    "Deva" => "Devanagari",
    "Ethi" => "Ethiopic",
    "Geor" => "Georgian",
    "Grek" => "Greek",
    "Gujr" => "Gujarati",
    "Guru" => "Gurmukhi",
    "Hani" => "Han",
    "Hang" => "Hangul",
    "Hebr" => "Hebrew",
    "Hira" => "Hiragana",
    "Khmr" => "Khmer",
    "Knda" => "Kannada",
    "Laoo" => "Lao",
    "Latn" => "Latin",
    "Mlym" => "Malayalam",
    "Mymr" => "Myanmar",
    "Orya" => "Oriya",
    "Sarb" => "Sarb",
    "Sinh" => "Sinhala",
    "Syrc" => "Syriac",
    "Taml" => "Tamil",
    "Telu" => "Telugu",
    "Thaa" => "Thaana",
    "Thai" => "Thai"
  }

  # Unicode script name -> BCP47 (ISO 15924) script code.
  # Used to convert transform IDs for the ICU demo site.
  @unicode_script_to_bcp47 @bcp47_script_to_unicode
                           |> Enum.map(fn {k, v} -> {v, k} end)
                           |> Map.new()

  # Reverse lookup: downcased canonical name -> canonical name
  # e.g., "arabic" => "Arabic", "nfc" => "NFC", "canadianaboriginal" => "CanadianAboriginal"
  @string_to_canonical_name @script_names
                            |> Map.values()
                            |> Enum.map(fn name -> {String.downcase(name), name} end)
                            |> Map.new()

  @doc """
  Resolves keyword options to a `{transform_id, direction}` tuple.

  ### Arguments

  * `options` — the keyword list of transform options.

  ### Returns

  * `{:ok, transform_id, direction}` when a specific transform is resolved.

  * `{:detect, to}` when script detection should be used.

  * `{:error, reason}` on invalid or missing options.

  """
  @spec resolve_options(keyword()) ::
          {:ok, String.t(), :forward | :reverse} | {:detect, term()} | {:error, term()}
  def resolve_options(options) do
    transform = Keyword.get(options, :transform)
    to = Keyword.get(options, :to)

    cond do
      is_binary(transform) ->
        direction = Keyword.get(options, :direction, :forward)
        {:ok, transform, direction}

      is_nil(to) ->
        {:error, {:missing_option, :to}}

      true ->
        from = Keyword.get(options, :from, :any)

        if from == :detect do
          {:detect, to}
        else
          resolve_from_to(from, to)
        end
    end
  end

  @doc """
  Converts a BCP47 (ISO 15924) script code to its Unicode script name.

  ### Arguments

  * `code` — a BCP47 script code string (e.g., `"Latn"`, `"Grek"`).

  ### Returns

  The Unicode script name string if found, or `nil`.

  ### Examples

      iex> Unicode.Transform.Resolve.bcp47_script_to_unicode("Latn")
      "Latin"

      iex> Unicode.Transform.Resolve.bcp47_script_to_unicode("Grek")
      "Greek"

      iex> Unicode.Transform.Resolve.bcp47_script_to_unicode("Unknown")
      nil

  """
  @spec bcp47_script_to_unicode(String.t()) :: String.t() | nil
  def bcp47_script_to_unicode(code) when is_binary(code) do
    Map.get(@bcp47_script_to_unicode, code)
  end

  @doc """
  Converts a Unicode script name to its BCP47 (ISO 15924) code.

  ### Arguments

  * `name` — a Unicode script name string (e.g., `"Latin"`, `"Greek"`).

  ### Returns

  The BCP47 code string if found, or `nil`.

  ### Examples

      iex> Unicode.Transform.Resolve.unicode_script_to_bcp47("Latin")
      "Latn"

      iex> Unicode.Transform.Resolve.unicode_script_to_bcp47("Greek")
      "Grek"

      iex> Unicode.Transform.Resolve.unicode_script_to_bcp47("Unknown")
      nil

  """
  @spec unicode_script_to_bcp47(String.t()) :: String.t() | nil
  def unicode_script_to_bcp47(name) when is_binary(name) do
    Map.get(@unicode_script_to_bcp47, name)
  end

  @doc """
  Converts a transform ID from BCP47 script codes to CLDR names.

  Replaces each segment of the transform ID that is a known BCP47
  script code with its CLDR full name.

  ### Arguments

  * `transform_id` — a transform ID string that may contain BCP47 codes.

  ### Returns

  The transform ID with BCP47 codes replaced by CLDR names.

  ### Examples

      iex> Unicode.Transform.Resolve.resolve_bcp47_transform_id("Grek-Latn")
      "Greek-Latin"

      iex> Unicode.Transform.Resolve.resolve_bcp47_transform_id("Cyrl-Latn")
      "Cyrillic-Latin"

      iex> Unicode.Transform.Resolve.resolve_bcp47_transform_id("Latin-ASCII")
      "Latin-ASCII"

  """
  @spec resolve_bcp47_transform_id(String.t()) :: String.t()
  def resolve_bcp47_transform_id(transform_id) when is_binary(transform_id) do
    transform_id
    |> String.split("-", parts: 2)
    |> Enum.map(fn segment -> Map.get(@bcp47_script_to_unicode, segment, segment) end)
    |> Enum.join("-")
  end

  @doc """
  Converts a transform ID from CLDR names to BCP47 script codes.

  Replaces each segment of the transform ID that is a known CLDR
  script name with its BCP47 code.

  ### Arguments

  * `transform_id` — a transform ID string that may contain CLDR names.

  ### Returns

  The transform ID with CLDR names replaced by BCP47 codes.

  ### Examples

      iex> Unicode.Transform.Resolve.to_bcp47_transform_id("Greek-Latin")
      "Grek-Latn"

      iex> Unicode.Transform.Resolve.to_bcp47_transform_id("Latin-ASCII")
      "Latn-ASCII"

      iex> Unicode.Transform.Resolve.to_bcp47_transform_id("de-ASCII")
      "de-ASCII"

  """
  @spec to_bcp47_transform_id(String.t()) :: String.t()
  def to_bcp47_transform_id(transform_id) when is_binary(transform_id) do
    transform_id
    |> String.split("-", parts: 2)
    |> Enum.map(fn segment -> Map.get(@unicode_script_to_bcp47, segment, segment) end)
    |> Enum.join("-")
  end

  @doc """
  Returns the canonical script name for a script atom.

  ### Arguments

  * `atom` — a script atom (e.g., `:greek`, `:grek`, `:latin`).

  ### Returns

  The canonical script name string if found, or `nil`.

  ### Examples

      iex> Unicode.Transform.Resolve.script_name(:greek)
      "Greek"

      iex> Unicode.Transform.Resolve.script_name(:grek)
      "Greek"

      iex> Unicode.Transform.Resolve.script_name(:unknown_script)
      nil

  """
  @spec script_name(atom()) :: String.t() | nil
  def script_name(atom) when is_atom(atom) do
    Map.get(@script_names, atom)
  end

  @doc """
  Resolves the target name from an atom or string.

  Used when resolving the target for script detection.

  ### Arguments

  * `to` — the target as an atom or string.

  ### Returns

  The canonical target name string, or `{:error, reason}`.

  """
  @spec resolve_to_name(atom() | String.t()) :: String.t() | {:error, term()}
  def resolve_to_name(to) when is_atom(to) do
    script_name(to) || to |> Atom.to_string() |> capitalize_name()
  end

  def resolve_to_name(to) when is_binary(to) do
    canonical_string_name(to)
  end

  # Resolve from/to to a transform ID and direction.
  defp resolve_from_to(from, to) do
    from_name = normalize_option_name(from)
    to_name = normalize_option_name(to)

    case {from_name, to_name} do
      {nil, _} -> {:error, {:invalid_option, {:from, from}}}
      {_, nil} -> {:error, {:invalid_option, {:to, to}}}
      {"Any", to_n} -> resolve_any_to(to_n)
      {from_n, to_n} -> resolve_transform_id(from_n, to_n)
    end
  end

  # Resolve "Any-X" transforms, checking builtins first, then files,
  # then falling back to script detection.
  defp resolve_any_to(to_name) do
    cond do
      Builtin.builtin?("Any-#{to_name}") ->
        {:ok, "Any-#{to_name}", :forward}

      Builtin.builtin?(to_name) ->
        {:ok, to_name, :forward}

      Loader.find_transform("Any-#{to_name}") != nil ->
        {:ok, "Any-#{to_name}", :forward}

      true ->
        # No specific Any-X transform exists; fall back to script detection
        {:detect, to_name}
    end
  end

  # Try "From-To" as a forward transform, then "To-From" as a reverse transform.
  defp resolve_transform_id(from_name, to_name) do
    forward_id = "#{from_name}-#{to_name}"

    if Builtin.builtin?(forward_id) || Loader.find_transform(forward_id) do
      {:ok, forward_id, :forward}
    else
      reverse_id = "#{to_name}-#{from_name}"

      if Loader.find_transform(reverse_id) do
        {:ok, reverse_id, :reverse}
      else
        # Fall back to forward_id and let do_transform produce the error
        {:ok, forward_id, :forward}
      end
    end
  end

  # Normalize an option value (atom or string) to its canonical string form.
  # Returns nil for unsupported types.
  defp normalize_option_name(value) when is_atom(value) do
    script_name(value) || value |> Atom.to_string() |> capitalize_name()
  end

  defp normalize_option_name(value) when is_binary(value) do
    canonical_string_name(value) |> capitalize_name()
  end

  defp normalize_option_name(_), do: nil

  # Capitalize the first letter of a name, preserving the rest.
  defp capitalize_name(<<first::utf8, rest::binary>>) do
    String.upcase(<<first::utf8>>) <> rest
  end

  defp capitalize_name(name), do: name

  # Resolve a string to its canonical form if it matches a known script name
  # (case-insensitive). Otherwise, return the string as-is.
  defp canonical_string_name(name) when is_binary(name) do
    Map.get(@string_to_canonical_name, String.downcase(name), name)
  end
end

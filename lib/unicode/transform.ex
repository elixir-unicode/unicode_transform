defmodule Unicode.Transform do
  @moduledoc """
  Implements the CLDR Transform specification for transforming
  text from one script to another.

  Transforms are defined by the [Unicode CLDR
  specification](https://unicode.org/reports/tr35/tr35-general.html#Transforms)
  and support operations such as transliteration between scripts,
  normalization, and case mapping.

  ## Examples

      iex> Unicode.Transform.transform("Ä Ö Ü ß", from: :latin, to: :ascii)
      {:ok, "A O U ss"}

      iex> Unicode.Transform.transform("hello", to: :upper)
      {:ok, "HELLO"}

      iex> Unicode.Transform.transform("Ä ö ü", transform: "de-ASCII")
      {:ok, "AE oe ue"}

  """

  alias Unicode.Transform.{Builtin, Compiler, Engine, Loader, Parser}

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

  @doc """
  Returns the default transform backend.

  ### Returns

  * `:nif` if the ICU NIF is loaded and available.

  * `:elixir` otherwise.

  """
  @spec default_backend() :: :nif | :elixir
  def default_backend do
    if Unicode.Transform.Nif.available?(), do: :nif, else: :elixir
  end

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

  @type transform_option ::
          {:from, atom() | String.t()}
          | {:to, atom() | String.t()}
          | {:transform, String.t()}
          | {:direction, :forward | :reverse}
          | {:backend, :nif | :elixir}

  @doc """
  Transforms a string using the specified transform.

  There are two ways to specify which transform to apply:

  1. **Script-based** — use `:from` and `:to` to specify source and target
     scripts as atoms. The transform ID and direction are inferred.

  2. **Direct** — use `:transform` with the string transform ID, and
     optionally `:direction` (default `:forward`).

  ### Arguments

  * `string` — the input string to transform.

  ### Options

  Either `:from`/`:to` or `:transform` must be provided:

  * `:to` — the target script as an atom or string (e.g., `:latin`,
    `"ASCII"`, `:upper`, `:nfc`). Required unless `:transform` is given.
    Resolution is case-insensitive.

  * `:from` — the source script as an atom or string (default: `:any`).
    E.g., `:greek`, `"Cyrillic"`. Resolution is case-insensitive.
    Use `:detect` to automatically detect scripts in the input
    and chain a transform for each detected script.

  * `:transform` — a string transform ID (e.g., `"de-ASCII"`,
    `"Armenian-Latin-BGN"`). Mutually exclusive with `:from`/`:to`.

  * `:direction` — `:forward` (default) or `:reverse`. Only used
    with `:transform`.

  * `:backend` — `:nif` or `:elixir`. Selects the transform engine.
    When set to `:nif`, transforms are executed via ICU4C's native
    transliterator. When set to `:elixir`, the pure-Elixir CLDR-based
    engine is used. Defaults to `:nif` when the NIF is available,
    otherwise `:elixir`.

  ### Returns

  * `{:ok, transformed_string}` on success.

  * `{:error, reason}` on failure.

  ### Examples

      iex> Unicode.Transform.transform("Ä Ö Ü ß", from: :latin, to: :ascii)
      {:ok, "A O U ss"}

      iex> Unicode.Transform.transform("αβγδ", from: :greek, to: :latin)
      {:ok, "abgd"}

      iex> Unicode.Transform.transform("hello", to: :upper)
      {:ok, "HELLO"}

      iex> Unicode.Transform.transform("Ä ö ü", transform: "de-ASCII")
      {:ok, "AE oe ue"}

  """
  @spec transform(String.t(), [transform_option()]) ::
          {:ok, String.t()} | {:error, term()}
  def transform(string, options) when is_list(options) do
    backend = Keyword.get(options, :backend, default_backend())

    case resolve_options(options) do
      {:ok, transform_id, direction} ->
        do_transform(string, transform_id, direction, backend)

      {:detect, to} ->
        transform_detected_scripts(string, to, backend)

      {:error, _} = error ->
        error
    end
  end

  @doc """
  Transforms a string using the specified transform, raising on error.

  ### Arguments

  * `string` — the input string to transform.

  ### Options

  Same as `transform/2`.

  ### Returns

  The transformed string.

  ### Examples

      iex> Unicode.Transform.transform!("Ä Ö Ü ß", from: :latin, to: :ascii)
      "A O U ss"

  """
  @spec transform!(String.t(), [transform_option()]) :: String.t()
  def transform!(string, options) when is_list(options) do
    case transform(string, options) do
      {:ok, result} -> result
      {:error, reason} -> raise ArgumentError, "Transform failed: #{inspect(reason)}"
    end
  end

  @doc """
  Returns a list of available transform IDs.

  ### Returns

  A list of transform ID strings.

  """
  @spec available_transforms() :: [String.t()]
  def available_transforms do
    Loader.list_transforms()
    |> Enum.map(&Loader.transform_id_from_file/1)
  end

  @doc """
  Converts a BCP47 (ISO 15924) script code to its Unicode script name.

  ### Arguments

  * `code` — a BCP47 script code string (e.g., `"Latn"`, `"Grek"`).

  ### Returns

  The Unicode script name string if found, or `nil`.

  ### Examples

      iex> Unicode.Transform.bcp47_script_to_unicode("Latn")
      "Latin"

      iex> Unicode.Transform.bcp47_script_to_unicode("Grek")
      "Greek"

      iex> Unicode.Transform.bcp47_script_to_unicode("Unknown")
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

      iex> Unicode.Transform.unicode_script_to_bcp47("Latin")
      "Latn"

      iex> Unicode.Transform.unicode_script_to_bcp47("Greek")
      "Grek"

      iex> Unicode.Transform.unicode_script_to_bcp47("Unknown")
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

      iex> Unicode.Transform.resolve_bcp47_transform_id("Grek-Latn")
      "Greek-Latin"

      iex> Unicode.Transform.resolve_bcp47_transform_id("Cyrl-Latn")
      "Cyrillic-Latin"

      iex> Unicode.Transform.resolve_bcp47_transform_id("Latin-ASCII")
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

      iex> Unicode.Transform.to_bcp47_transform_id("Greek-Latin")
      "Grek-Latn"

      iex> Unicode.Transform.to_bcp47_transform_id("Latin-ASCII")
      "Latn-ASCII"

      iex> Unicode.Transform.to_bcp47_transform_id("de-ASCII")
      "de-ASCII"

  """
  @spec to_bcp47_transform_id(String.t()) :: String.t()
  def to_bcp47_transform_id(transform_id) when is_binary(transform_id) do
    transform_id
    |> String.split("-", parts: 2)
    |> Enum.map(fn segment -> Map.get(@unicode_script_to_bcp47, segment, segment) end)
    |> Enum.join("-")
  end

  # Internal transform function used by the engine for transitive
  # rule resolution and by the compiler callback. Accepts a string
  # transform ID directly.
  @doc false
  @spec do_transform(String.t(), String.t(), :forward | :reverse, :nif | :elixir) ::
          {:ok, String.t()} | {:error, term()}
  def do_transform(string, transform_id, direction, backend \\ nil)

  def do_transform(string, transform_id, direction, nil) do
    do_transform(string, transform_id, direction, default_backend())
  end

  def do_transform(string, transform_id, direction, :nif) do
    case nif_transform(string, transform_id, direction) do
      {:ok, _} = result ->
        result

      :not_available ->
        # Fall back to Elixir engine if NIF doesn't recognize the transform
        do_transform_elixir(string, transform_id, direction)
    end
  end

  def do_transform(string, transform_id, direction, :elixir) do
    do_transform_elixir(string, transform_id, direction)
  end

  defp do_transform_elixir(string, transform_id, direction) do
    case compiled_module_transform(string, transform_id, direction) do
      {:ok, _} = result ->
        result

      :not_found ->
        case get_compiled_transform(transform_id, direction) do
          {:ok, compiled} ->
            {:ok, Engine.execute(string, compiled)}

          {:error, _} = error ->
            error
        end
    end
  end

  # Dispatch to ICU via the NIF when available.
  # Returns {:ok, result} on success, or :not_available if the NIF
  # is not loaded or ICU doesn't recognize the transform ID.
  defp nif_transform(string, transform_id, direction) do
    if Unicode.Transform.Nif.available?() do
      dir = if direction == :forward, do: 0, else: 1

      case Unicode.Transform.Nif.transform(transform_id, string, dir) do
        {:ok, _} = result -> result
        {:error, _} -> :not_available
      end
    else
      :not_available
    end
  end

  # Compiled module fast paths for common transforms.
  # These bypass the cursor-based engine entirely.
  defp compiled_module_transform(string, "Latin-ASCII", :forward) do
    {:ok, Unicode.Transform.LatinAscii.transform(string)}
  end

  defp compiled_module_transform(_string, _transform_id, _direction), do: :not_found

  # Scripts that should be skipped when detecting — they don't represent
  # a meaningful source script for transliteration.
  @skip_scripts [:common, :inherited, :unknown]

  # Detect scripts in the string and chain transforms for each one.
  defp transform_detected_scripts(string, to, backend) do
    to_name = resolve_to_name(to)

    case to_name do
      {:error, _} = error ->
        error

      name ->
        scripts =
          Unicode.script_dominance(string)
          |> Enum.reject(fn {script, _} -> script in @skip_scripts end)
          |> Enum.map(fn {script, _} -> script end)

        Enum.reduce_while(scripts, {:ok, string}, fn script, {:ok, acc} ->
          from_name = script_name(script)

          if from_name do
            transform_id = "#{from_name}-#{name}"

            case do_transform(acc, transform_id, :forward, backend) do
              {:ok, result} -> {:cont, {:ok, result}}
              {:error, _} = error -> {:halt, error}
            end
          else
            {:cont, {:ok, acc}}
          end
        end)
    end
  end

  defp resolve_to_name(to) when is_atom(to) do
    script_name(to) || to |> Atom.to_string() |> capitalize_name()
  end

  defp resolve_to_name(to) when is_binary(to) do
    canonical_string_name(to)
  end

  # Resolve keyword options to a {transform_id, direction} tuple.
  defp resolve_options(options) do
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

  # Resolve "Any-X" transforms, checking builtins first.
  defp resolve_any_to(to_name) do
    cond do
      Builtin.builtin?("Any-#{to_name}") ->
        {:ok, "Any-#{to_name}", :forward}

      Builtin.builtin?(to_name) ->
        {:ok, to_name, :forward}

      true ->
        {:ok, "Any-#{to_name}", :forward}
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

  defp script_name(atom) when is_atom(atom) do
    Map.get(@script_names, atom)
  end

  # Resolve a string to its canonical form if it matches a known script name
  # (case-insensitive). Otherwise, return the string as-is.
  defp canonical_string_name(name) when is_binary(name) do
    Map.get(@string_to_canonical_name, String.downcase(name), name)
  end

  # Get or compile a transform, using the Cache GenServer to
  # serialize compilation and persistent_term for storage.
  defp get_compiled_transform(transform_id, direction) do
    Unicode.Transform.Cache.get_or_compile(transform_id, direction, fn ->
      compile_transform(transform_id, direction)
    end)
  end

  defp compile_transform(transform_id, direction) do
    # Try built-in first
    if Builtin.builtin?(transform_id) do
      {:ok, Compiler.compile_builtin(transform_id, direction)}
    else
      compile_from_file(transform_id, direction)
    end
  end

  defp compile_from_file(transform_id, direction) do
    case Loader.find_transform(transform_id) do
      {file_path, file_direction} ->
        data = Loader.load_file(file_path)
        rules = Parser.parse(data.rules)

        # Combine file direction with requested direction
        effective_direction = combine_directions(direction, file_direction)
        compiled = Compiler.compile(rules, effective_direction, &resolve_transform/2)
        {:ok, compiled}

      nil ->
        {:error, {:unknown_transform, transform_id}}
    end
  end

  # When the file itself is the backward alias (e.g., ConjoiningJamo-Latin found via
  # Latin-ConjoiningJamo.xml), we need to adjust the direction accordingly.
  defp combine_directions(:forward, :forward), do: :forward
  defp combine_directions(:forward, :backward), do: :reverse
  defp combine_directions(:reverse, :forward), do: :reverse
  defp combine_directions(:reverse, :backward), do: :forward

  # Resolve a transform name to a function that transforms a string.
  # This is passed to the engine so it can invoke sub-transforms.
  # Uses string-based IDs since CLDR rules reference transforms by name.
  defp resolve_transform(name, direction) do
    fn string ->
      case do_transform(string, name, direction) do
        {:ok, result} -> result
        {:error, _} -> string
      end
    end
  end
end

defmodule Unicode.Transform do
  @moduledoc """
  Implements the CLDR Transform specification for transforming
  text from one script to another.

  Transforms are defined by the [Unicode CLDR
  specification](https://unicode.org/reports/tr35/tr35-general.html#Transforms)
  and support operations such as transliteration between scripts,
  normalization, and case mapping.

  ## Usage

      iex> Unicode.Transform.transform("Ä Ö Ü ß", from: :latin, to: :ascii)
      {:ok, "A O U ss"}

      iex> Unicode.Transform.transform("hello", to: :upper)
      {:ok, "HELLO"}

      iex> Unicode.Transform.transform("Ä ö ü", transform: "de-ASCII")
      {:ok, "AE oe ue"}

  """

  alias Unicode.Transform.{Builtin, Compiler, Engine, Loader, Parser}

  @script_names %{
    # Scripts
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

  @type transform_option ::
          {:from, atom() | String.t()}
          | {:to, atom() | String.t()}
          | {:transform, String.t()}
          | {:direction, :forward | :reverse}

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

  * `:to` — the target script as an atom (e.g., `:latin`, `:ascii`,
    `:upper`, `:nfc`). Required unless `:transform` is given.

  * `:from` — the source script as an atom (default: `:any`).
    E.g., `:greek`, `:cyrillic`.

  * `:transform` — a string transform ID (e.g., `"de-ASCII"`,
    `"Armenian-Latin-BGN"`). Mutually exclusive with `:from`/`:to`.

  * `:direction` — `:forward` (default) or `:reverse`. Only used
    with `:transform`.

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
    case resolve_options(options) do
      {:ok, transform_id, direction} ->
        do_transform(string, transform_id, direction)

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

  # Internal transform function used by the engine for transitive
  # rule resolution and by the compiler callback. Accepts a string
  # transform ID directly.
  @doc false
  @spec do_transform(String.t(), String.t(), :forward | :reverse) ::
          {:ok, String.t()} | {:error, term()}
  def do_transform(string, transform_id, direction) do
    case get_compiled_transform(transform_id, direction) do
      {:ok, compiled} ->
        {:ok, Engine.execute(string, compiled)}

      {:error, _} = error ->
        error
    end
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
        resolve_from_to(from, to)
    end
  end

  defp resolve_from_to(from, to) when is_atom(from) and is_atom(to) do
    case resolve_atom_options(from, to) do
      {:ok, id} -> {:ok, id, :forward}
      error -> error
    end
  end

  defp resolve_from_to(from, to) when is_atom(from) and is_binary(to) do
    from_name = script_name(from)

    if from_name do
      {:ok, "#{from_name}-#{to}", :forward}
    else
      {:error, {:unknown_script, from}}
    end
  end

  defp resolve_from_to(from, to) when is_binary(from) and is_atom(to) do
    to_name = script_name(to)

    if to_name do
      {:ok, "#{from}-#{to_name}", :forward}
    else
      {:error, {:unknown_script, to}}
    end
  end

  defp resolve_from_to(from, to) when is_binary(from) and is_binary(to) do
    {:ok, "#{from}-#{to}", :forward}
  end

  defp resolve_from_to(from, to) do
    {:error, {:invalid_options, [from: from, to: to]}}
  end

  defp resolve_atom_options(:any, to) do
    to_name = script_name(to)

    cond do
      is_nil(to_name) ->
        {:error, {:unknown_script, to}}

      # Try "Any-X" first (for built-ins like Any-Upper, Any-NFC)
      Builtin.builtin?("Any-#{to_name}") ->
        {:ok, "Any-#{to_name}"}

      # Then try bare name (for NFC, NFD, Upper, Lower, etc.)
      Builtin.builtin?(to_name) ->
        {:ok, to_name}

      # Otherwise construct "Any-X" as the transform ID
      true ->
        {:ok, "Any-#{to_name}"}
    end
  end

  defp resolve_atom_options(from, to) do
    from_name = script_name(from)
    to_name = script_name(to)

    cond do
      is_nil(from_name) -> {:error, {:unknown_script, from}}
      is_nil(to_name) -> {:error, {:unknown_script, to}}
      true -> {:ok, "#{from_name}-#{to_name}"}
    end
  end

  defp script_name(atom) when is_atom(atom) do
    Map.get(@script_names, atom)
  end

  # Get or compile a transform
  defp get_compiled_transform(transform_id, direction) do
    cache_key = {transform_id, direction}

    case lookup_cache(cache_key) do
      {:ok, compiled} ->
        {:ok, compiled}

      :miss ->
        case compile_transform(transform_id, direction) do
          {:ok, compiled} ->
            store_cache(cache_key, compiled)
            {:ok, compiled}

          error ->
            error
        end
    end
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

  # Simple ETS-based cache for compiled transforms
  @cache_table :unicode_transform_cache

  defp ensure_cache_table do
    case :ets.whereis(@cache_table) do
      :undefined ->
        :ets.new(@cache_table, [:named_table, :set, :public, read_concurrency: true])

      _ref ->
        :ok
    end
  end

  defp lookup_cache(key) do
    ensure_cache_table()

    case :ets.lookup(@cache_table, key) do
      [{^key, compiled}] -> {:ok, compiled}
      [] -> :miss
    end
  rescue
    ArgumentError -> :miss
  end

  defp store_cache(key, value) do
    ensure_cache_table()
    :ets.insert(@cache_table, {key, value})
  rescue
    ArgumentError -> :ok
  end
end

defmodule Unicode.Transform do
  @moduledoc """
  Implements the CLDR Transform specification for transforming
  text from one script to another.

  Transforms are defined by the [Unicode CLDR
  specification](https://unicode.org/reports/tr35/tr35-general.html#Transforms)
  and support operations such as transliteration between scripts,
  normalization, and case mapping.

  ### Usage Examples

      iex> Unicode.Transform.transform("Ä Ö Ü ß", from: :latin, to: :ascii)
      {:ok, "A O U ss"}

      iex> Unicode.Transform.transform("hello", to: :upper)
      {:ok, "HELLO"}

      iex> Unicode.Transform.transform("Ä ö ü", transform: "de-ASCII")
      {:ok, "AE oe ue"}

  ### Transform ID resolution

  When `transform/2` is called, the transform ID is resolved through
  one of two paths depending on the options provided.

  #### Direct ID (`:transform` option)

  The string is used as-is. If the ID is not found as a built-in or
  in the CLDR transform files, and it has the form `"Any-Target"`,
  the library falls back to automatic script detection (see below).

  #### Script-based (`:from` / `:to` options)

  The `:from` and `:to` values are normalized to canonical script
  names (case-insensitive, supporting both Unicode names like `:greek`
  and BCP47 codes like `:grek`). Resolution then proceeds as follows:

  1. **Built-in check** — if the ID matches a built-in transform
     (e.g., `Any-NFC`, `Any-Upper`), it is dispatched directly
     to the corresponding `String` function.

  2. **Forward file lookup** — the library looks for a CLDR XML
     file matching `"From-To"` (e.g., `"Greek-Latin"`), checking
     the alias index built from file metadata.

  3. **Reverse file lookup** — if no forward match is found,
     the library looks for `"To-From"` and marks the direction
     as `:reverse` (e.g., `to: :greek, from: :latin` resolves
     to `"Greek-Latin"` in reverse).

  4. **BCP47 fallback** — if neither exact nor case-insensitive
     matches succeed, the ID is resolved as a BCP47 transform
     ID (e.g., `"Grek-Latn"` → `"Greek-Latin"`).

  #### The `Any` source and script detection

  When `:from` is `:any` (the default) or when a `transform: "Any-X"`
  ID is used, `unicode_transform` first checks for a specific `Any-X` transform
  (built-in or file-based, such as `Any-Accents` or `Any-Publishing`).

  If no specific `Any-X` transform exists, the library falls back to
  **automatic script detection**: it calls `Unicode.script_dominance/1`
  to identify the scripts present in the input string, then chains
  a `{detected_script}-X` transform for each detected script. Common,
  inherited, and unknown scripts are skipped.

  For example, `transform("αβγδ абвг", from: :any, to: :latin)` detects
  Greek and Cyrillic, then applies `Greek-Latin` followed by
  `Cyrillic-Latin`.

  This is equivalent to using `from: :detect`, which always uses script
  detection without checking for a specific `Any-X` transform first.

  #### Sub-transform narrowing

  CLDR transform files can reference sub-transforms via `::Name;`
  rules. When a sub-transform is a bare script name (e.g., `::Latin;`
  inside `Greek-Latin.xml`), it is narrowed using the parent
  transform's source and target scripts — resolving `::Latin;` to
  `Greek-Latin`. Sub-transforms that are already compound names
  (e.g., `::Bengali-InterIndic;`) or built-ins (e.g., `::NFC;`)
  are used as-is.

  """

  alias Unicode.Transform.{Builtin, Compiler, Engine, Loader, Parser, Resolve}

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

  See the [Transform ID resolution](#module-transform-id-resolution) section in the
  module documentation for details on how transform IDs are resolved,
  including `Any-` handling and automatic script detection.

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

    case Resolve.resolve_options(options) do
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

  # Internal transform function used by the engine for transitive
  # rule resolution and by the compiler callback. Accepts a string
  # transform ID directly.
  @doc false
  @spec do_transform(String.t(), String.t(), :forward | :reverse, :nif | :elixir | nil) ::
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

          {:error, {:unknown_transform, id}} ->
            maybe_detect_any(string, id)

          {:error, _} = error ->
            error
        end
    end
  end

  # When an "Any-X" transform has no specific file, fall back to
  # script detection — detect the input script and chain the
  # appropriate {detected_script}-X transforms.
  defp maybe_detect_any(string, transform_id) do
    case String.split(transform_id, "-", parts: 2) do
      ["Any", target] ->
        transform_detected_scripts(string, target, default_backend())

      _ ->
        {:error, {:unknown_transform, transform_id}}
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
    to_name = Resolve.resolve_to_name(to)

    case to_name do
      {:error, _} = error ->
        error

      name ->
        scripts =
          Unicode.script_dominance(string)
          |> Enum.reject(fn {script, _} -> script in @skip_scripts end)
          |> Enum.map(fn {script, _} -> script end)

        Enum.reduce_while(scripts, {:ok, string}, fn script, {:ok, acc} ->
          from_name = Resolve.script_name(script)

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

        # Build context for sub-transform narrowing: bare script names
        # like ::Latin; inside Greek-Latin.xml resolve to Greek-Latin.
        source = Resolve.bcp47_script_to_unicode(data.source) || data.source
        target = Resolve.bcp47_script_to_unicode(data.target) || data.target
        context = %{source: source, target: target}

        compiled =
          Compiler.compile(rules, effective_direction, &resolve_transform/2, context)

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

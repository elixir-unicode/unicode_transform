defmodule Unicode.Transform do
  @moduledoc """
  Implements the CLDR Transform specification for transforming
  text from one script to another.

  Transforms are defined by the [Unicode CLDR
  specification](https://unicode.org/reports/tr35/tr35-general.html#Transforms)
  and support operations such as transliteration between scripts,
  normalization, and case mapping.

  ## Usage

      iex> Unicode.Transform.transform("Ä Ö Ü ß", "Latin-ASCII")
      {:ok, "A O U ss"}

      iex> Unicode.Transform.transform("hello", "Any-Upper")
      {:ok, "HELLO"}
  """

  alias Unicode.Transform.{Builtin, Compiler, Engine, Loader, Parser}

  @doc """
  Transforms a string using the named transform.

  ### Arguments

  * `string` — the input string to transform
  * `transform_id` — the name of the transform (e.g., `"Latin-ASCII"`)
  * `direction` — `:forward` or `:reverse` (default: `:forward`)

  ### Returns

  * `{:ok, transformed_string}` on success
  * `{:error, reason}` on failure

  ### Examples

      iex> Unicode.Transform.transform("Ä Ö Ü ß", "Latin-ASCII")
      {:ok, "A O U ss"}
  """
  @spec transform(String.t(), String.t(), :forward | :reverse) ::
          {:ok, String.t()} | {:error, term()}
  def transform(string, transform_id, direction \\ :forward) do
    case get_compiled_transform(transform_id, direction) do
      {:ok, compiled} ->
        {:ok, Engine.execute(string, compiled)}

      {:error, _} = error ->
        error
    end
  end

  @doc """
  Transforms a string using the named transform, raising on error.

  ### Arguments

  * `string` — the input string to transform
  * `transform_id` — the name of the transform
  * `direction` — `:forward` or `:reverse` (default: `:forward`)

  ### Returns

  The transformed string.

  ### Examples

      iex> Unicode.Transform.transform!("Ä Ö Ü ß", "Latin-ASCII")
      "A O U ss"
  """
  @spec transform!(String.t(), String.t(), :forward | :reverse) :: String.t()
  def transform!(string, transform_id, direction \\ :forward) do
    case transform(string, transform_id, direction) do
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
  defp resolve_transform(name, direction) do
    fn string ->
      case transform(string, name, direction) do
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

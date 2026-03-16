defmodule Unicode.Transform.Loader do
  @moduledoc """
  Loads CLDR transform definitions from XML files.

  Uses SweetXml to parse the XML and extract the transform
  metadata and rule text.

  """

  import SweetXml

  @alias_index_key :unicode_transform_alias_index

  @doc """
  Loads a transform definition from an XML file.

  ### Arguments

  * `file_path` — path to the XML file.

  ### Returns

  A map with the following keys:

  * `:source` — source script/locale.

  * `:target` — target script/locale.

  * `:direction` — `"forward"`, `"backward"`, or `"both"`.

  * `:alias` — transform alias string.

  * `:backward_alias` — backward transform alias string.

  * `:rules` — the raw rule text string.

  """
  @spec load_file(Path.t()) :: map()
  def load_file(file_path) do
    file_path
    |> File.read!()
    |> String.replace(~r/<!DOCTYPE.*>\n/, "")
    |> xpath(~x"//transform",
      source: ~x"./@source"s,
      target: ~x"./@target"s,
      direction: ~x"./@direction"s,
      alias: ~x"./@alias"s,
      backward_alias: ~x"./@backwardAlias"s,
      rules: ~x"./tRule/text()"s
    )
  end

  @doc """
  Returns the default transforms directory path.

  ### Returns

  The path to the transforms directory.

  """
  @spec transforms_dir() :: Path.t()
  def transforms_dir do
    Path.join(:code.priv_dir(:unicode_transform), "transforms")
  end

  @doc """
  Lists all available transform XML files.

  ### Returns

  A list of file paths to transform XML files.

  """
  @spec list_transforms() :: [Path.t()]
  def list_transforms do
    transforms_dir()
    |> Path.join("*.xml")
    |> Path.wildcard()
    |> Enum.sort()
  end

  @doc """
  Finds the XML file path and direction for a given transform ID.

  Resolves transform names by checking:

  1. Exact filename match (e.g., `"Latin-ASCII"` → `"priv/transforms/Latin-ASCII.xml"`).

  2. Forward alias match from XML metadata.

  3. Backward alias match from XML metadata.

  4. Reverse direction lookup (e.g., `"ConjoiningJamo-Latin"` found via
     `"Latin-ConjoiningJamo.xml"` with `direction="both"`).

  5. BCP47 (ISO 15924) script code resolution (e.g., `"Grek-Latn"` →
     `"Greek-Latin"`).

  ### Arguments

  * `transform_id` — the transform name to resolve.

  ### Returns

  * `{file_path, :forward}` — use the file's rules in forward direction.

  * `{file_path, :backward}` — use the file's rules in backward/reverse direction.

  * `nil` — no matching transform found.

  """
  @spec find_transform(String.t()) :: {Path.t(), :forward | :backward} | nil
  def find_transform(transform_id) do
    index = ensure_alias_index()

    case Map.get(index, transform_id) do
      nil ->
        # Try case-insensitive
        case Map.get(index, String.downcase(transform_id)) do
          nil ->
            # Try resolving BCP47 script codes to Unicode names
            resolved = Unicode.Transform.Resolve.resolve_bcp47_transform_id(transform_id)

            if resolved != transform_id do
              case Map.get(index, resolved) do
                nil -> Map.get(index, String.downcase(resolved))
                result -> result
              end
            else
              nil
            end

          result ->
            result
        end

      result ->
        result
    end
  end

  @doc """
  Derives a transform ID from source and target.

  ### Arguments

  * `source` — the source script name.

  * `target` — the target script name.

  ### Returns

  A string like `"Latin-ASCII"` or `"Greek-Latin"`.

  """
  @spec transform_id(String.t(), String.t()) :: String.t()
  def transform_id(source, target) do
    "#{source}-#{target}"
  end

  @doc """
  Derives a transform ID from a filename.

  ### Arguments

  * `file_path` — the path to the XML file.

  ### Returns

  A string transform ID derived from the filename.

  """
  @spec transform_id_from_file(Path.t()) :: String.t()
  def transform_id_from_file(file_path) do
    file_path
    |> Path.basename(".xml")
  end

  @doc """
  Builds the alias index from all transform XML files and stores
  it in a `persistent_term`. Called at application startup to
  avoid lazy initialization on the first transform call.

  ### Returns

  The alias index map.

  """
  @spec build_alias_index() :: map()
  def build_alias_index do
    index =
      list_transforms()
      |> Enum.reduce(%{}, fn file_path, acc ->
        index_transform_file(acc, file_path)
      end)

    :persistent_term.put(@alias_index_key, index)
    index
  end

  # Get or build the alias index as a persistent_term map
  defp ensure_alias_index do
    try do
      :persistent_term.get(@alias_index_key)
    rescue
      ArgumentError -> build_alias_index()
    end
  end

  defp index_transform_file(index, file_path) do
    try do
      data = load_file(file_path)

      # Index forward aliases first (these are authoritative)
      index =
        if data.alias != "" do
          data.alias
          |> String.split(" ")
          |> Enum.reduce(index, fn alias_name, acc ->
            acc
            |> Map.put(alias_name, {file_path, :forward})
            |> Map.put(String.downcase(alias_name), {file_path, :forward})
            |> put_base_alias(alias_name, file_path, :forward)
          end)
        else
          index
        end

      # Index backward aliases (use put_new so forward aliases take priority)
      index =
        if data.backward_alias != "" do
          data.backward_alias
          |> String.split(" ")
          |> Enum.reduce(index, fn alias_name, acc ->
            acc
            |> Map.put_new(alias_name, {file_path, :backward})
            |> Map.put_new(String.downcase(alias_name), {file_path, :backward})
            |> put_new_base_alias(alias_name, file_path, :backward)
          end)
        else
          index
        end

      # Index by filename-derived ID only if not already indexed by alias
      file_id = transform_id_from_file(file_path)

      index =
        index
        |> Map.put_new(file_id, {file_path, :forward})
        |> Map.put_new(String.downcase(file_id), {file_path, :forward})

      # For direction="both", also index the reverse ID
      if data.direction == "both" do
        case reverse_transform_id(file_id) do
          nil ->
            index

          reverse_id ->
            index
            |> Map.put_new(reverse_id, {file_path, :backward})
            |> Map.put_new(String.downcase(reverse_id), {file_path, :backward})
        end
      else
        index
      end
    rescue
      _ -> index
    end
  end

  # Store base alias (without /Variant suffix) using Map.put
  defp put_base_alias(index, alias_name, file_path, direction) do
    base = alias_name |> String.split("/") |> hd()

    if base != alias_name do
      index
      |> Map.put_new(base, {file_path, direction})
      |> Map.put_new(String.downcase(base), {file_path, direction})
    else
      index
    end
  end

  # Store base alias (without /Variant suffix) using Map.put_new
  defp put_new_base_alias(index, alias_name, file_path, direction) do
    base = alias_name |> String.split("/") |> hd()

    if base != alias_name do
      index
      |> Map.put_new(base, {file_path, direction})
      |> Map.put_new(String.downcase(base), {file_path, direction})
    else
      index
    end
  end

  defp reverse_transform_id(id) do
    case String.split(id, "-", parts: 2) do
      [source, target] -> "#{target}-#{source}"
      _ -> nil
    end
  end
end

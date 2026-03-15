defmodule Unicode.Transform.Builtin do
  @moduledoc """
  Implements built-in transforms defined by the Unicode Standard.

  These transforms are not defined by rules but by operations
  in the Unicode Standard:

  * `Any-NFC`, `Any-NFD`, `Any-NFKC`, `Any-NFKD` — normalization forms
  * `Any-Lower`, `Any-Upper`, `Any-Title` — case transformations
  * `Any-Null` — identity (no effect)
  * `Any-Remove` — removes all characters
  """

  @builtin_transforms %{
    "NFC" => :nfc,
    "NFD" => :nfd,
    "NFKC" => :nfkc,
    "NFKD" => :nfkd,
    "Any-NFC" => :nfc,
    "Any-NFD" => :nfd,
    "Any-NFKC" => :nfkc,
    "Any-NFKD" => :nfkd,
    "Lower" => :lower,
    "Upper" => :upper,
    "Title" => :title,
    "Any-Lower" => :lower,
    "Any-Upper" => :upper,
    "Any-Title" => :title,
    "Null" => :null,
    "Any-Null" => :null,
    "Remove" => :remove,
    "Any-Remove" => :remove,
    "Any-BreakInternal" => :null,
    "BreakInternal" => :null
  }

  @doc """
  Returns whether the given transform name is a built-in transform.

  ### Arguments

  * `name` — the transform name string

  ### Returns

  `true` if the transform is built-in, `false` otherwise.
  """
  @spec builtin?(String.t()) :: boolean()
  def builtin?(name) do
    Map.has_key?(@builtin_transforms, normalize_name(name))
  end

  @doc """
  Applies a built-in transform to a string.

  ### Arguments

  * `string` — the input string
  * `name` — the transform name

  ### Returns

  The transformed string.

  ### Examples

      iex> Unicode.Transform.Builtin.apply("Ä", "NFD")
      "Ä"

      iex> Unicode.Transform.Builtin.apply("hello", "Upper")
      "HELLO"
  """
  @spec apply(String.t(), String.t()) :: String.t()
  def apply(string, name) do
    case Map.get(@builtin_transforms, normalize_name(name)) do
      :nfc -> String.normalize(string, :nfc)
      :nfd -> String.normalize(string, :nfd)
      :nfkc -> String.normalize(string, :nfkc)
      :nfkd -> String.normalize(string, :nfkd)
      :lower -> String.downcase(string)
      :upper -> String.upcase(string)
      :title -> title_case(string)
      :null -> string
      :remove -> ""
      nil -> raise ArgumentError, "Unknown built-in transform: #{inspect(name)}"
    end
  end

  @doc """
  Returns the inverse of a built-in transform name.

  ### Arguments

  * `name` — the transform name

  ### Returns

  The inverse transform name, or `nil` if no inverse exists.
  """
  @spec inverse(String.t()) :: String.t() | nil
  def inverse(name) do
    case normalize_name(name) do
      n when n in ["NFC", "Any-NFC"] -> "NFD"
      n when n in ["NFD", "Any-NFD"] -> "NFC"
      n when n in ["NFKC", "Any-NFKC"] -> "NFKD"
      n when n in ["NFKD", "Any-NFKD"] -> "NFKC"
      n when n in ["Lower", "Any-Lower"] -> "Upper"
      n when n in ["Upper", "Any-Upper"] -> "Lower"
      n when n in ["Title", "Any-Title"] -> "Lower"
      n when n in ["Null", "Any-Null"] -> "Null"
      n when n in ["Remove", "Any-Remove"] -> nil
      _ -> nil
    end
  end

  # Normalize a transform name for lookup
  defp normalize_name(name) do
    canonical =
      name
      |> String.trim()
      |> String.replace(~r/\(\)$/, "")
      |> String.trim()

    # Try exact match first, then case-insensitive
    if Map.has_key?(@builtin_transforms, canonical) do
      canonical
    else
      Enum.find_value(@builtin_transforms, canonical, fn {key, _val} ->
        if String.downcase(key) == String.downcase(canonical), do: key
      end)
    end
  end

  defp title_case(string) do
    string
    |> String.split(~r/(\s+)/u, include_captures: true)
    |> Enum.map(fn word ->
      case String.next_grapheme(word) do
        {first, rest} -> String.upcase(first) <> String.downcase(rest)
        nil -> ""
      end
    end)
    |> Enum.join()
  end
end

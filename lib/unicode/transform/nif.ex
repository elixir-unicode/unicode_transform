defmodule Unicode.Transform.Nif do
  @moduledoc """
  Optional NIF-based Unicode transforms using ICU4C.

  This module provides high-performance Unicode transliteration by wrapping
  ICU4C's `utrans` API via a Native Interface Function (NIF). When available,
  transforms are dispatched to ICU for execution; otherwise, the pure-Elixir
  engine is used automatically.

  The NIF is opt-in and requires:

  1. ICU system libraries installed (`libicu` or `icucore` on macOS).

  2. The `elixir_make` dependency.

  3. Enable the NIF via either:
     - Environment variable: `UNICODE_TRANSFORM_NIF=true mix compile`
     - Application config in `config.exs`:
       `config :unicode_transform, :nif, true`

  The config key must be set in `config.exs` (not `runtime.exs`) because
  it is evaluated at compile time to include the `:elixir_make` compiler.

  If the NIF is not available, `available?/0` returns `false` and the
  pure-Elixir implementation is used automatically.

  """

  @on_load :init

  @doc false
  def init do
    path = :code.priv_dir(:unicode_transform) ++ ~c"/utransform"

    case :erlang.load_nif(path, 0) do
      :ok -> :ok
      {:error, _reason} -> :ok
    end
  end

  @doc """
  Returns whether the NIF transform backend is available.

  ### Returns

  * `true` if the NIF shared library was loaded successfully.

  * `false` if the NIF is not compiled or ICU libraries are missing.

  ### Examples

      iex> is_boolean(Unicode.Transform.Nif.available?())
      true

  """
  @spec available?() :: boolean()
  def available? do
    try do
      case transform("Any-Null", "", 0) do
        {:ok, _} -> true
        _ -> false
      end
    rescue
      _ -> false
    end
  end

  @doc """
  Transforms a string using an ICU transliterator.

  ### Arguments

  * `id` — the ICU transform ID (e.g., `"Latin-ASCII"`, `"Greek-Latin"`).

  * `text` — the input string to transform.

  * `direction` — `0` for forward (`UTRANS_FORWARD`),
    `1` for reverse (`UTRANS_REVERSE`).

  ### Returns

  * `{:ok, result}` on success.

  * `{:error, reason}` on failure.

  """
  @dialyzer {:no_return, transform: 3}
  @spec transform(String.t(), String.t(), 0 | 1) :: {:ok, String.t()} | {:error, String.t()}
  def transform(_id, _text, _direction) do
    :erlang.nif_error(:nif_library_not_loaded)
  end

  @doc """
  Returns a list of all ICU-registered transliterator IDs.

  ### Returns

  A list of transform ID strings (e.g., `["ASCII-Latin", "Any-Accents", ...]`).

  """
  @dialyzer {:no_return, available_ids: 0}
  @spec available_ids() :: [String.t()]
  def available_ids do
    :erlang.nif_error(:nif_library_not_loaded)
  end
end

defmodule Unicode.Transform.Cache do
  @moduledoc false

  use GenServer

  @cache_key :unicode_transform_compiled_cache

  # Client API

  def start_link(options \\ []) do
    GenServer.start_link(__MODULE__, options, name: __MODULE__)
  end

  @doc false
  def get_or_compile(transform_id, direction, compile_fn) do
    cache_key = {transform_id, direction}

    case lookup(cache_key) do
      {:ok, compiled} ->
        {:ok, compiled}

      :miss ->
        GenServer.call(__MODULE__, {:compile, cache_key, compile_fn}, :infinity)
    end
  end

  defp lookup(key) do
    cache = :persistent_term.get(@cache_key, %{})

    case Map.get(cache, key) do
      nil -> :miss
      compiled -> {:ok, compiled}
    end
  end

  # Server callbacks

  @impl true
  def init(_options) do
    :persistent_term.put(@cache_key, %{})
    {:ok, %{}}
  end

  @impl true
  def handle_call({:compile, cache_key, compile_fn}, _from, state) do
    # Double-check under the lock — another caller may have compiled
    # this transform while we were waiting.
    cache = :persistent_term.get(@cache_key, %{})

    case Map.get(cache, cache_key) do
      nil ->
        result = compile_fn.()

        case result do
          {:ok, compiled} ->
            updated = Map.put(cache, cache_key, compiled)
            :persistent_term.put(@cache_key, updated)
            {:reply, {:ok, compiled}, state}

          error ->
            {:reply, error, state}
        end

      compiled ->
        {:reply, {:ok, compiled}, state}
    end
  end
end

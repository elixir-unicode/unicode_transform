defmodule Unicode.Transform.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type \\ :normal, _args \\ []) do
    Unicode.Transform.Loader.build_alias_index()

    children = [
      Unicode.Transform.Cache
    ]

    options = [strategy: :one_for_one, name: Unicode.Transform.Supervisor]
    Supervisor.start_link(children, options)
  end
end

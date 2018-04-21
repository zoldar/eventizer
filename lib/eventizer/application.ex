defmodule Eventizer.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = []

    {:ok, _} = Registry.start_link(keys: :duplicate, name: Eventizer.Dispatcher)

    opts = [strategy: :one_for_one, name: Eventizer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

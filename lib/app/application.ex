defmodule App.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    topologies = Application.get_env(:libcluster, :topologies)

    children = [
      {Cluster.Supervisor, [topologies, [name: App.ClusterSupervisor]]},
      App.WorkerSupervisor
      # ..other children..
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: App.Supervisor)
  end
end

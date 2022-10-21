defmodule App do
  @cluster_name :app

  def start_worker(name) do
    {:ok, pid} = Swarm.register_name(name, App.WorkerSupervisor, :register, [name])
    Swarm.join(@cluster_name, pid)
  end

  def workers(), do: Swarm.members(@cluster_name)
end

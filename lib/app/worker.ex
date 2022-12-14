defmodule App.Worker do
  use GenServer, restart: :transient
  require Logger

  @moduledoc """
  This is the worker process, in this case, it simply posts on a
  random recurring interval to stdout.
  """

  def start_link([name]) do
    GenServer.start_link(__MODULE__, name)
  end

  def init(name) do
    Process.send_after(self(), :tick, 1000)
    {:ok, {name, 0}}
  end

  # called when a handoff has been initiated due to changes
  # in cluster topology, valid response values are:
  #
  #   - `:restart`, to simply restart the process on the new node
  #   - `{:resume, state}`, to hand off some state to the new process
  #   - `:ignore`, to leave the process running on its current node
  #
  def handle_call({:swarm, :begin_handoff}, _from, {name, count}) do
    {:reply, {:resume, count}, {name, count}}
  end

  # called after the process has been restarted on its new node,
  # and the old process' state is being handed off. This is only
  # sent if the return to `begin_handoff` was `{:resume, state}`.
  # **NOTE**: This is called *after* the process is successfully started,
  # so make sure to design your processes around this caveat if you
  # wish to hand off state like this.
  def handle_cast({:swarm, :end_handoff, count}, {name, _}) do
    {:noreply, {name, count}}
  end

  # called when a network split is healed and the local process
  # should continue running, but a duplicate process on the other
  # side of the split is handing off its state to us. You can choose
  # to ignore the handoff state, or apply your own conflict resolution
  # strategy
  def handle_cast({:swarm, :resolve_conflict, _count}, state) do
    {:noreply, state}
  end

  def handle_info(:tick, {name, count}) do
    count = count + 1
    Logger.info("#{name} (#{inspect(self())}): #{count}")

    Process.send_after(self(), :tick, 1000)
    {:noreply, {name, count}}
  end

  # this message is sent when this process should die
  # because it is being moved, use this as an opportunity
  # to clean up
  def handle_info({:swarm, :die}, state) do
    {:stop, :shutdown, state}
  end
end

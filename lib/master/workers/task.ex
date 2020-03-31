defmodule Workers.Task do
  @moduledoc false
  use GenServer, restart: :transient
  require IEx
  require Logger
  @next_activity_time 60

  @impl true
  def init(state) do
    schedule_next_activity(state)
    {:ok, state}
  end

  def start_link(state \\ []) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def handle_info(:run_activity, state) do
    Logger.info("Start task activity")
    deploy = Master.Repo.get_by(Master.Deploy, status: :in_progress)

    if !deploy do
      Tasks.ProcessInProgress.call()
      Tasks.ProcessNew.call()
    end

    schedule_next_activity(state)
  end

  @impl true
  def handle_info(_msg, state), do: {:noreply, state}

  def schedule_next_activity(state) do
    Process.send_after(self(), :run_activity, @next_activity_time * 1_000)
    {:noreply, state}
  end
end

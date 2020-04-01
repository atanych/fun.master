defmodule Workers.Tar do
  @moduledoc false
  use GenServer, restart: :transient
  require IEx
  require Logger
  require Ecto.Query

  @next_activity_time 10

  @impl true
  def init(state) do
    schedule_next_activity(state)
    {:ok, state}
  end

  def start_link(state \\ []) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def handle_info(:run_activity, state) do
    Logger.info("Start TAR processing")

    Master.Task
    |> Tasks.ServerQuery.call()
    |> Master.Repo.where(status: :ready_to_tar)
    |> Master.Repo.order_by(asc: :inserted_at)
    |> Ecto.Query.limit(30)
    |> Master.Repo.all()
    |> Enum.each(&Tasks.Tar.call/1)

    Logger.info("Complete TAR processing")

    schedule_next_activity(state)
  end

  @impl true
  def handle_info(_msg, state), do: {:noreply, state}

  def schedule_next_activity(state) do
    Process.send_after(self(), :run_activity, @next_activity_time * 1_000)
    {:noreply, state}
  end
end

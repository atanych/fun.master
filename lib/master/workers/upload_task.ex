defmodule Workers.UploadTask do
  @moduledoc false
  use GenServer, restart: :transient
  require IEx
  require Logger
  require Ecto.Query
  @next_activity_time 30

  @impl true
  def init(state) do
    schedule_next_activity(state)
    {:ok, state}
  end

  def start_link(state \\ []) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  @impl true
  def handle_info(:run_activity, state) do
    Logger.info("Start upload task activity")

    Master.UploadTask
    |> Tasks.ServerQuery.call()
    |> Master.Repo.where(status: :new)
    |> Master.Repo.order_by(asc: :inserted_at)
    |> Ecto.Query.limit(30)
    |> Master.Repo.all()
    |> Enum.each(&UploadTasks.Process.call/1)

    schedule_next_activity(state)
  end

  @impl true
  def handle_info(_msg, state), do: {:noreply, state}

  def schedule_next_activity(state) do
    Process.send_after(self(), :run_activity, @next_activity_time * 1_000)
    {:noreply, state}
  end
end

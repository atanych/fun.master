defmodule Tasks.ProcessNew do
  @moduledoc false
  require IEx
  require Logger

  def call do
    Master.Task
    |> Tasks.ServerQuery.call()
    |> Master.Repo.where(%{status: :new})
    |> Master.Repo.all()
    |> Master.Repo.preload([:server])
    |> Enum.reduce(nil, &handle_task(&1, &2))
  end

  def handle_task(task, server) do
    {:ok, server} =
      Master.Repo.transaction(fn ->
        worker =
          Master.Worker |> Master.Repo.lock_for_update() |> Master.Repo.where(status: :ready) |> Master.Repo.first()

        if worker do
          Master.Repo.save!(task, %{status: :in_progress, worker_id: worker.id})
          worker |> Master.Repo.save!(%{status: :busy}) |> Workers.Transcoding.call(task)
          Servers.ChangeReserved.call(server || task.server, :increase)
        end
      end)

    server
  end
end

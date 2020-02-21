defmodule Tasks.ProcessNew do
  @moduledoc false
  require Ecto.Query
  require IEx
  require Logger

  def call do
    Master.Task
    |> Tasks.ServerQuery.call()
    |> Master.Repo.where(%{status: :new})
    |> Master.Repo.order_by(asc: :inserted_at)
    |> Ecto.Query.limit(20)
    |> Master.Repo.all()
    |> Master.Repo.preload([:server])
    |> Enum.reduce(nil, &handle_task(&1, &2))
  end

  def handle_task(task, server) do
    {:ok, server} = Master.Repo.transaction(fn -> task |> get_file_status() |> handle_file_status(task, server) end)
    server
  end

  def get_file_status(task) do
    args = [
      "-oStrictHostKeyChecking=no",
      "-i",
      "devops/origin.key",
      "-p2022",
      "root@#{task.origin_server_ip}",
      "ls",
      "/mnt/#{task.origin_url}"
    ]

    case System.cmd("ssh", args, stderr_to_stdout: true) do
      {_, 0} ->
        "exist"

      {error, _} ->
        Logger.error("Error if check origin path - #{inspect(error)}, task - #{inspect(task)}")
        "not_found"
    end
  end

  def handle_file_status("not_found", task, server) do
    Master.Repo.save(task, %{status: :file_not_found})
    server
  end

  def handle_file_status(_, task, server) do
    worker = Master.Worker |> Master.Repo.lock_for_update() |> Master.Repo.where(status: :ready) |> Master.Repo.first()

    if worker do
      Master.Repo.save!(task, %{status: :in_progress, worker_id: worker.id})
      worker |> Workers.ChangeStatus.call(:busy) |> Workers.Transcoding.call(task)
      Servers.ChangeReserved.call(server || task.server, :increase)
    end
  end
end

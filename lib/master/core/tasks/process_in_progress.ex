defmodule Tasks.ProcessInProgress do
  @moduledoc false
  require IEx
  require Logger

  def call do
    Master.Task
    |> Tasks.ServerQuery.call()
    |> Master.Repo.where(%{status: :in_progress})
    |> Master.Repo.order_by(asc: :updated_at)
    |> Master.Repo.all()
    |> Master.Repo.preload([:worker, :server])
    |> Enum.each(&handle_task(&1))
  end

  def handle_task(task) do
    status = Workers.GetTranscodingStatus.call(task)
    if status in ["ready", "bad_file"], do: status_handler(status, task)
  end

  def status_handler(status, task) do
    Master.Repo.transaction(fn ->
      worker = Master.Worker |> Master.Repo.lock_for_update() |> Master.Repo.get(task.worker_id)

      if status == "ready" do
        %{pid: pid} = Task.async(fn -> Workers.Loading.call(task) end)
        Master.Repo.save!(task, %{status: :loading, pid: Ext.Utils.Base.encode(pid)})
      else
        Master.Repo.save!(task, %{status: :bad_file})
      end

      Servers.ChangeReserved.call(task.server.id, :decrease)
      Workers.ChangeStatus.call(worker, :ready)
    end)
  end
end

defmodule Tasks.ProcessInProgress do
  @moduledoc false
  require IEx
  require Logger

  def call do
    Master.Task
    |> Tasks.ServerQuery.call()
    |> Master.Repo.where(%{status: :in_progress})
    |> Master.Repo.all()
    |> Master.Repo.preload([:worker, :server])
    |> Enum.each(&handle_task(&1))
  end

  def handle_task(task) do
    status = Workers.GetTranscodingStatus.call(task)

    if status == "ready" do
      %{pid: pid} = Task.async(fn -> Workers.Loading.call(task) end)
      Master.Repo.save!(task, %{status: :loading, pid: Ext.Utils.Base.encode(pid)})
      Master.Repo.save!(task.worker, %{status: :ready})
    end
  end
end

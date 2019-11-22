defmodule Workers.Loading do
  @moduledoc false
  require IEx
  require Logger

  def call(task) do
    Logger.warn("START LOADING FROM WORKER - #{inspect(task)}")
    Master.Repo.save!(task, %{status: :done})
    Servers.ChangeReserved.call(task.server, :decrease)
  end
end

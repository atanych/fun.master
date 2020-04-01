defmodule Tasks.Tar do
  @moduledoc false
  require Ecto.Query
  require IEx
  require Logger

  def call(task) do
    folder_path_list = task.url |> String.split("/") |> Enum.drop(-1)
    folder_path = Enum.join(folder_path_list, "/")

    Ext.System.cmd!("tar", ["czf", "#{folder_path}.tar", folder_path])

    Ext.System.cmd!("rm", ["-R", folder_path])

    Master.Repo.save!(task, status: :done)
  rescue
    e in RuntimeError ->
      Logger.warn("Task to tar has error - #{inspect(e)}")

      # Hack, tar exists but we have error
      folder_path_list = task.url |> String.split("/") |> Enum.drop(-1)

      if File.exists?(Enum.join(folder_path_list, "/") <> ".tar") do
        Logger.warn("Task exists - #{inspect(task)}")
        Master.Repo.save!(task, status: :done)
      else
        Logger.warn("Task not exists - #{inspect(task)}")
        Master.Repo.save!(task, status: :new)
      end
  end
end

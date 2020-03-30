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
    _e in RuntimeError -> Master.Repo.save!(task, status: :new)
  end
end

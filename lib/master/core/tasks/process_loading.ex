defmodule Tasks.ProcessLoading do
  @moduledoc false
  require IEx
  require Logger

  def call do
    Master.Task
    |> Tasks.ServerQuery.call()
    |> Master.Repo.where(%{status: :loading})
    |> Master.Repo.all()
    |> Enum.each(fn task ->
      unless task.pid |> Ext.Utils.Base.decode() |> Process.alive?(),
        do: Master.Repo.save!(task, %{status: :done})
    end)
  end
end

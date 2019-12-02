defmodule Workers.GetTranscodingStatus do
  @moduledoc false
  require IEx
  require Logger

  def call(task) do
    args = ["tail -n 1 #{Ext.Config.get([:workers, :origin_path])}/#{task.server.name}/#{task.movie_uuid}/status.txt"]

    case System.cmd("ssh", Workers.BuildSshArgs.call(task.worker, args), stderr_to_stdout: true) do
      {status, 0} ->
        status

      {error, _} ->
        if String.downcase(error) =~ "no such file or directory", do: Master.Repo.save!(task, %{status: :new})
        Logger.error("Status for worker - #{inspect(task.worker)} complete with error - #{inspect(error)}")
        nil
    end
  end
end

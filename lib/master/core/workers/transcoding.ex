defmodule Workers.Transcoding do
  @moduledoc false
  require Logger

  def call(worker, task) do
    name = task.origin_url |> String.split("/") |> List.last()
    string_args = "#{task.movie_uuid} #{task.origin_server_ip} #{task.origin_url} #{name} #{task.server.name}"
    args = ["cd /home/scripts; nohup python3 transcode.py #{string_args} > nohup.out /dev/null 2>&1 &"]

    case System.cmd("ssh", Workers.BuildSshArgs.call(worker, args), stderr_to_stdout: true) do
      {_, 0} ->
        :ok

      {error, _} ->
        Master.Repo.save!(task, %{status: :new})
        Logger.error("Task - #{inspect(task)} not started, on worker - #{inspect(worker)}, error - #{inspect(error)}")
        :error
    end
  end
end

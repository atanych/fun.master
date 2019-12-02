defmodule Workers.Transcoding do
  @moduledoc false
  require Logger

  def call(worker, task) do
    args = [
      "cd /home/scripts; nohup python3 transcode.py #{task.server.name} #{task.movie_uuid} #{task.origin_url} > nohup.out /dev/null 2>&1 &"
    ]

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

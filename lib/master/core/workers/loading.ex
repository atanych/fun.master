defmodule Workers.Loading do
  @moduledoc false
  require IEx
  require Logger

  def call(task) do
    with :ok <- download(task),
         :ok <- remove(task) do
    else
      {:error, error} -> Logger.error(error)
    end
  end

  def download(task) do
    disk = Servers.GetSpace.call() |> Ext.Utils.Enum.randomize_by(:available_space) |> Map.get(:dir)
    week = Timex.format!(Timex.now(), "%W", :strftime)
    content_path = "#{Ext.Config.get(:self_name)}/#{disk}/#{week}"
    File.mkdir_p!(content_path)
    loading_path = "#{Ext.Config.get([:workers, :transcode_path])}/#{task.server.name}/#{task.movie_uuid}"
    args = [loading_path, content_path]

    "scp"
    |> System.cmd(Workers.BuildSshArgs.call(task.worker, args, :scp), stderr_to_stdout: true)
    |> handle_download(task, content_path)
  end

  def remove(task) do
    origin_dir = "#{Ext.Config.get([:workers, :origin_path])}/#{task.server.name}/#{task.movie_uuid}"
    transcode_dir = "#{Ext.Config.get([:workers, :transcode_path])}/#{task.server.name}/#{task.movie_uuid}"
    args = ["rm -r #{origin_dir} #{transcode_dir}"]

    case System.cmd("ssh", Workers.BuildSshArgs.call(task.worker, args), stderr_to_stdout: true) do
      {_, 0} -> :ok
      {error, _} -> {:error, "Remove dirs error - #{inspect(error)}"}
    end
  end

  def handle_download({_, 0}, task, url) do
    Master.Repo.save!(task, %{status: :ready_to_tar, url: "#{url}/#{task.movie_uuid}/master.m3u8"})
    space = Servers.GetSpace.call()

    Master.Repo.transaction(fn ->
      server = Master.Server |> Master.Repo.lock_for_update() |> Master.Repo.get(task.server.id)

      Master.Repo.save!(server, %{
        total_space: Ext.Utils.Enum.sum_by(space, & &1.total_space),
        available_space: Ext.Utils.Enum.sum_by(space, & &1.available_space)
      })
    end)

    :ok
  end

  def handle_download({error, _}, _, _), do: {:error, "Download movie error - #{inspect(error)}"}
end

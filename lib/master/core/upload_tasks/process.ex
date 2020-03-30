defmodule UploadTasks.Process do
  @moduledoc false
  require Ecto.Query
  require IEx
  require Logger
  alias Master.UploadTask
  import Ext.Utils.Map

  def call(%UploadTask{} = task) do
    Logger.info("Upload task #{task.id} is started. CDN #{task.cdn_info["id"]}")

    store_key(task)
    Master.Repo.save!(task, %{status: :in_progress})

    upload_file!(task)
    Master.Repo.save!(task, %{status: :uploaded})

    {total, available} = get_cdn_server_capacity!(task)
    # coveralls-ignore-start
    Logger.info("Upload task #{task.id} is uploaded. CDN #{task.cdn_info["id"]}, space=#{available}Gb/#{total}Gb")
    # coveralls-ignore-stop
    cdn_info = task.cdn_info ||| %{"available_capacity" => available, "total_capacity" => total}
    Master.Repo.save!(task, %{cdn_info: cdn_info})
  rescue
    e in RuntimeError ->
      Master.Repo.save!(task, %{status: :failed})
      Logger.error("Upload task #{task.id} is failed. #{inspect(e)}")
  end

  defp upload_file!(task) do
    movie_dir = "/root/storage/priv/static/movies"
    folder_path_list = task.url |> String.split("/") |> Enum.drop(-1)
    tar_path = Enum.join(folder_path_list, "/") <> ".tar"
    mkdir_path = "/" <> (folder_path_list |> Enum.drop(-1) |> Enum.join("/"))

    Ext.System.cmd!("ssh", [
      "root@#{task.cdn_info["ip"]}",
      "-i",
      get_cdn_key(task),
      "mkdir",
      "-p",
      movie_dir <> mkdir_path
    ])

    Ext.System.cmd!("scp", ["-i", get_cdn_key(task), tar_path, "root@#{task.cdn_info["ip"]}:#{movie_dir}#{mkdir_path}"])

    Ext.System.cmd!("ssh", [
      "root@#{task.cdn_info["ip"]}",
      "-i",
      get_cdn_key(task),
      "tar",
      "-xzvf",
      movie_dir <> "/" <> tar_path,
      "-C",
      movie_dir
    ])

    Ext.System.cmd!("ssh", [
      "root@#{task.cdn_info["ip"]}",
      "-i",
      get_cdn_key(task),
      "rm",
      "-R",
      movie_dir <> "/" <> Enum.join(folder_path_list, "/") <> "/"
    ])
  end

  defp store_key(task) do
    File.mkdir("cdn_keys")
    path = get_cdn_key(task)
    File.write(path, task.cdn_info["ssh_key"])
    File.chmod!(path, 0o400)
  end

  defp get_cdn_key(%{cdn_info: cdn_info}), do: "cdn_keys/cdn_#{cdn_info["id"]}.pem"

  defp get_cdn_server_capacity!(%{cdn_info: cdn_info} = task) do
    %{out: out} =
      Ext.System.cmd!("ssh", [
        "root@#{cdn_info["ip"]}",
        "-i",
        get_cdn_key(task),
        "df -P",
        "|",
        "awk '/^\\// { print $1\" \"$2\" \"$3\" \"$4 }'"
      ])

    [_mount, total, _used, available] = out |> to_string() |> String.split("\n") |> hd() |> String.split(" ")
    {String.to_integer(total) / (1_024 * 1_024), String.to_integer(available) / (1_024 * 1_024)}
  end
end

defmodule Workers.LoadingTest do
  use MasterWeb.ConnCase
  import ExUnit.CaptureLog

  setup_with_mocks([{File, [:passthrough], [ls!: fn _ -> ["d1"] end]}]) do
    server =
      insert(:server,
        name: "def_1",
        total_space: 100,
        available_space: 100,
        reserved_space: Ext.Config.get([Servers.ChangeReserved, :default_reserve])
      )

    worker = insert(:worker, ip: "192.168.1.1", status: :busy)
    task = insert(:task, server: server, movie_uuid: Ecto.UUID.generate(), status: :loading, worker: worker)
    %{task: task}
  end

  test "Error download dir", %{task: task} do
    with_mocks([{System, [:passthrough], [cmd: fn "scp", _, _ -> {"no file", 1} end]}]) do
      logs = capture_log(fn -> Workers.Loading.call(task) end)

      assert logs =~ "Download movie error"
    end
  end

  test "Error remove dirs on remote server", %{task: task} do
    with_mocks([
      {System, [:passthrough],
       [
         cmd: fn
           "scp", _, _ -> {"", 0}
           "ssh", _, _ -> {"no file", 1}
         end
       ]}
    ]) do
      logs = capture_log(fn -> Workers.Loading.call(task) end)

      assert logs =~ "Remove dirs error"
    end
  end

  test "Download file and remove dirs is correct", %{task: task} do
    with_mocks([
      {System, [:passthrough],
       [
         cmd: fn "df", _ ->
           {"Filesystem     Size   Used  Avail Capacity iused               ifree %iused  Mounted on\n/dev/disk1s1  233Gi  103Gi  127Gi    45% 3075447 9223372036851700360    0%   /\n",
            0}
         end
       ]},
      {System, [:passthrough],
       [
         cmd: fn
           "scp", _, _ -> {"", 0}
           "ssh", _, _ -> {"", 0}
         end
       ]}
    ]) do
      Workers.Loading.call(task)
      url = "content/d1/#{Timex.format!(Timex.now(), "%W", :strftime)}/#{task.movie_uuid}/master.m3u8"
      server = Master.Repo.reload(task.server)
      task = Master.Repo.reload(task)
      assert %{status: :done, url: ^url} = task
      assert %{total_space: 233, available_space: 127, reserved_space: 0} = server
    end
  end
end

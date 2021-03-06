defmodule Workers.UploadTaskTest do
  use MasterWeb.ConnCase

  describe "handle_info(:run_activity)" do
    test_with_mock "common case", Ext.System,
      cmd!: fn
        "ssh", _ -> %{out: "/dev/sda1 2097152 1709156 1048576"}
        _, _ -> nil
      end do
      server1 = insert(:server, name: System.get_env("SELF_NAME"))
      server2 = insert(:server, name: "another")

      insert(:upload_task,
        status: :new,
        server: server1,
        url: "m1/disk2/08/621d4cee-38aa-4ee7-89e1-50a5ef821aa3/master.m3u8",
        cdn_info: %{id: 1, ssh_key: "KEY"}
      )

      insert(:upload_task, status: :new, server: server2)
      insert(:upload_task, status: :in_progress, server: server1)
      Workers.UploadTask.handle_info(:run_activity, [])

      [task] = Master.UploadTask |> Master.Repo.where(server_id: server2.id) |> Master.Repo.all()
      assert task.status == :new

      statuses =
        Master.UploadTask |> Master.Repo.where(server_id: server1.id) |> Master.Repo.all() |> Enum.map(& &1.status)

      assert_lists(statuses, [:in_progress, :uploaded])

      assert_called(
        Ext.System.cmd!("ssh", [
          "root@#{task.cdn_info["ip"]}",
          "-i",
          :_,
          "mkdir",
          "-p",
          "/var/storage/movies/m1/disk2/08"
        ])
      )

      assert_called(
        Ext.System.cmd!("scp", [
          "-i",
          :_,
          "m1/disk2/08/621d4cee-38aa-4ee7-89e1-50a5ef821aa3.tar",
          "root@#{task.cdn_info["ip"]}:/var/storage/movies/m1/disk2/08"
        ])
      )

      assert_called(
        Ext.System.cmd!("ssh", [
          "root@#{task.cdn_info["ip"]}",
          "-i",
          :_,
          "tar",
          "-xzvf",
          "/var/storage/movies/m1/disk2/08/621d4cee-38aa-4ee7-89e1-50a5ef821aa3.tar",
          "-C",
          "/var/storage/movies"
        ])
      )

      assert_called(
        Ext.System.cmd!("ssh", [
          "root@#{task.cdn_info["ip"]}",
          "-i",
          :_,
          "rm",
          "-R",
          "/var/storage/movies/m1/disk2/08/621d4cee-38aa-4ee7-89e1-50a5ef821aa3.tar"
        ])
      )

      uploaded_task = Master.Repo.get_by(Master.UploadTask, server_id: server1.id, status: :uploaded)
      assert %{"available_capacity" => 1.0, "total_capacity" => 2.0} = uploaded_task.cdn_info
    end

    test_with_mock "error during upload", Ext.System, cmd!: fn "ssh", _ -> raise "bung!" end do
      server1 = insert(:server, name: System.get_env("SELF_NAME"))

      insert(:upload_task,
        status: :new,
        server: server1,
        url: "m1/disk2/08/621d4cee-38aa-4ee7-89e1-50a5ef821aa3/master.m3u8",
        cdn_info: %{id: 1, ssh_key: "KEY"}
      )

      Workers.UploadTask.handle_info(:run_activity, [])

      assert Master.Repo.get_by(Master.UploadTask, server_id: server1.id, status: :failed)
    end
  end
end

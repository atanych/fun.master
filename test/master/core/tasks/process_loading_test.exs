defmodule Tasks.ProcessLoadingTest do
  use MasterWeb.ConnCase

  setup_with_mocks([{Ext.Config, [], [get: fn :self_name -> "def_1" end]}]) do
    :ok
  end

  describe ".call" do
    test "if exists tasks in status :loading and pid exist" do
      with_mocks([
        {Workers.GetTranscodingStatus, [], [call: fn _ -> "busy" end]},
        {Workers.Loading, [], [call: fn _ -> "" end]}
      ]) do
        server = insert(:server, name: "def_1", total_space: 100, available_space: 100)
        worker = insert(:worker, ip: "192.168.1.1", status: :busy)
        uuid = Ecto.UUID.generate()
        %{pid: pid} = Task.async(fn -> :timer.sleep(3_000) end)

        insert(:task,
          server_id: server.id,
          movie_uuid: uuid,
          status: :loading,
          worker_id: worker.id,
          pid: Ext.Utils.Base.encode(pid)
        )

        Tasks.ProcessLoading.call()
        tasks = Master.Task |> Master.Repo.where(status: :loading) |> Master.Repo.all()
        assert length(tasks) == 1
      end
    end

    test "if exists tasks in status :loading and pid not exist" do
      with_mocks([
        {Workers.GetTranscodingStatus, [], [call: fn _ -> "busy" end]},
        {Workers.Loading, [], [call: fn _ -> "" end]}
      ]) do
        server = insert(:server, name: "def_1", total_space: 100, available_space: 100)
        worker = insert(:worker, ip: "192.168.1.1", status: :busy)
        uuid = Ecto.UUID.generate()
        %{pid: pid} = Task.async(fn -> "" end)

        insert(:task,
          server_id: server.id,
          movie_uuid: uuid,
          status: :loading,
          worker_id: worker.id,
          pid: Ext.Utils.Base.encode(pid)
        )

        Tasks.ProcessLoading.call()
        tasks = Master.Task |> Master.Repo.where(status: :ready_to_tar) |> Master.Repo.all()
        assert length(tasks) == 1
      end
    end
  end
end

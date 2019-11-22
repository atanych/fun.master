defmodule Tasks.ProcessInProgressTest do
  use MasterWeb.ConnCase

  setup_with_mocks([{Ext.Config, [], [get: fn :self_name -> "def_1" end]}]) do
    :ok
  end

  describe ".call" do
    test "if no tasks in status :in_progress" do
      with_mocks([{Tasks.ProcessInProgress, [:passthrough], [handle_task: fn _ -> "" end]}]) do
        Tasks.ProcessInProgress.call()
        refute called(Tasks.ProcessInProgress.handle_task(:_))
      end
    end

    test "if exists tasks in status :in_progress and not ready transcoding" do
      with_mocks([
        {Workers.GetTranscodingStatus, [], [call: fn _ -> "busy" end]},
        {Workers.Loading, [], [call: fn _ -> "" end]}
      ]) do
        server = insert(:server, name: "def_1", total_space: 100, available_space: 100)
        worker = insert(:worker, ip: "192.168.1.1", status: :busy)
        uuid = Ecto.UUID.generate()
        insert(:task, server_id: server.id, movie_uuid: uuid, status: :in_progress, worker_id: worker.id)
        Tasks.ProcessInProgress.call()
        tasks = Master.Task |> Master.Repo.where(status: :in_progress) |> Master.Repo.all()
        assert length(tasks) == 1
        refute called(Workers.Loading.call(:_))
      end
    end

    test "if exists tasks in status :in_progress and ready transcoding" do
      with_mocks([
        {Workers.GetTranscodingStatus, [], [call: fn _ -> "ready" end]},
        {Workers.Loading, [], [call: fn _ -> "" end]}
      ]) do
        server = insert(:server, name: "def_1", total_space: 100, available_space: 100)
        worker = insert(:worker, ip: "192.168.1.1", status: :busy)
        uuid = Ecto.UUID.generate()
        insert(:task, server_id: server.id, movie_uuid: uuid, status: :in_progress, worker_id: worker.id)
        Tasks.ProcessInProgress.call()
        tasks = Master.Task |> Master.Repo.where(status: :loading) |> Master.Repo.all()
        worker = Master.Repo.reload(worker)
        assert length(tasks) == 1
        assert worker.status == :ready
        assert called(Workers.Loading.call(:_))
      end
    end
  end
end

defmodule Tasks.ProcessNewTest do
  use MasterWeb.ConnCase

  setup_with_mocks([
    {Ext.Config, [],
     [
       get: fn
         [Servers.ChangeReserved, :default_reserve] -> 10
         _ -> "def_1"
       end
     ]}
  ]) do
    :ok
  end

  describe ".call" do
    test "if no tasks in status new" do
      with_mocks([{Tasks.ProcessNew, [:passthrough], [handle_task: fn _, _ -> "" end]}]) do
        Tasks.ProcessNew.call()
        refute called(Tasks.ProcessNew.handle_task(:_))
      end
    end

    test "if exists tasks in status new and no workers" do
      with_mocks([
        {System, [:passthrough], [cmd: fn _, _, _ -> {"", 0} end]},
        {Workers.Transcoding, [], [call: fn _, _ -> "" end]}
      ]) do
        server = insert(:server, name: "def_1", total_space: 100, available_space: 100)
        insert(:task, server_id: server.id, movie_uuid: Ecto.UUID.generate())
        insert(:task, server_id: server.id, movie_uuid: Ecto.UUID.generate())
        Tasks.ProcessNew.call()
        tasks = Master.Task |> Master.Repo.where(status: :new) |> Master.Repo.all()
        server = Master.Repo.reload(server)
        assert length(tasks) == 2
        assert server.reserved_space == 0
        refute called(Workers.Transcoding.call(:_, :_))
      end
    end

    test "if exists tasks in status new and has one workers, start one task" do
      with_mocks([
        {System, [:passthrough], [cmd: fn _, _, _ -> {"", 0} end]},
        {Workers.Transcoding, [], [call: fn _, _ -> "" end]}
      ]) do
        server = insert(:server, name: "def_1", total_space: 100, available_space: 100)
        insert(:worker, ip: "192.168.1.1", status: :ready, max_tasks: 1)
        insert(:task, server_id: server.id, movie_uuid: Ecto.UUID.generate())
        insert(:task, server_id: server.id, movie_uuid: Ecto.UUID.generate())
        Tasks.ProcessNew.call()
        tasks = Master.Task |> Master.Repo.where(status: :in_progress) |> Master.Repo.all()
        worker = Master.Repo.first(Master.Worker)
        server = Master.Repo.reload(server)
        assert length(tasks) == 1
        assert worker.status == :busy
        assert server.reserved_space == Ext.Config.get([Servers.ChangeReserved, :default_reserve])
        assert called(Workers.Transcoding.call(:_, :_))
      end
    end

    test "if exists tasks in status new and has one workers, start two task" do
      with_mocks([
        {System, [:passthrough], [cmd: fn _, _, _ -> {"", 0} end]},
        {Workers.Transcoding, [], [call: fn _, _ -> "" end]}
      ]) do
        server = insert(:server, name: "def_1", total_space: 100, available_space: 100)
        insert(:worker, ip: "192.168.1.1", status: :ready, max_tasks: 1)
        insert(:worker, ip: "192.168.1.2", status: :ready, max_tasks: 1)
        insert(:task, server_id: server.id, movie_uuid: Ecto.UUID.generate())
        insert(:task, server_id: server.id, movie_uuid: Ecto.UUID.generate())
        Tasks.ProcessNew.call()
        tasks = Master.Task |> Master.Repo.where(status: :in_progress) |> Master.Repo.all()
        worker_statuses = Master.Worker |> Master.Repo.all() |> Enum.map(& &1.status)
        server = Master.Repo.reload(server)
        assert length(tasks) == 2
        assert worker_statuses == [:busy, :busy]
        assert server.reserved_space == 2 * Ext.Config.get([Servers.ChangeReserved, :default_reserve])
        assert called(Workers.Transcoding.call(:_, :_))
      end
    end

    test "origin_url does not exist, task has status file_not_found" do
      with_mocks([
        {System, [:passthrough], [cmd: fn _, _, _ -> {"", 1} end]},
        {Workers.Transcoding, [], [call: fn _, _ -> "" end]}
      ]) do
        server = insert(:server, name: "def_1", total_space: 100, available_space: 100)
        insert(:worker, ip: "192.168.1.1", status: :ready, max_tasks: 1)
        insert(:task, server_id: server.id, movie_uuid: Ecto.UUID.generate())
        Tasks.ProcessNew.call()
        tasks = Master.Task |> Master.Repo.where(status: :file_not_found) |> Master.Repo.all()
        worker_statuses = Master.Worker |> Master.Repo.all() |> Enum.map(& &1.status)
        assert length(tasks) == 1
        assert worker_statuses == [:ready]
        refute called(Workers.Transcoding.call(:_, :_))
      end
    end
  end
end

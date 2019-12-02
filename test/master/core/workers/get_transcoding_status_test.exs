defmodule Workers.GetTranscodingStatusTest do
  use MasterWeb.ConnCase

  setup do
    server = insert(:server, name: "def_1", total_space: 100, available_space: 100)
    worker = insert(:worker, ip: "192.168.1.1", status: :busy)
    uuid = Ecto.UUID.generate()
    task = insert(:task, server: server, movie_uuid: uuid, status: :in_progress, worker: worker)
    %{task: task}
  end

  test "status ready", %{task: task} do
    with_mocks([{System, [:passthrough], [cmd: fn _, _, _ -> {"ready", 0} end]}]) do
      status = Workers.GetTranscodingStatus.call(task)
      assert status == "ready"
      task = Master.Repo.reload(task)
      assert task.status == :in_progress
    end
  end

  test "status busy", %{task: task} do
    with_mocks([{System, [:passthrough], [cmd: fn _, _, _ -> {"busy", 0} end]}]) do
      status = Workers.GetTranscodingStatus.call(task)
      assert status == "busy"
      task = Master.Repo.reload(task)
      assert task.status == :in_progress
    end
  end

  test "status not found error no such file or directory", %{task: task} do
    with_mocks([{System, [:passthrough], [cmd: fn _, _, _ -> {"no such file or directory", 1} end]}]) do
      status = Workers.GetTranscodingStatus.call(task)
      assert is_nil(status)
      task = Master.Repo.reload(task)
      assert task.status == :new
    end
  end
end

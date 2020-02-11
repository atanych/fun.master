defmodule Workers.TranscodingTest do
  use MasterWeb.ConnCase

  setup do
    server = insert(:server, name: "def_1", total_space: 100, available_space: 100)
    worker = insert(:worker, ip: "192.168.1.1", status: :busy, max_tasks: 1, tasks_in_progress: 1)
    uuid = Ecto.UUID.generate()
    task = insert(:task, server: server, movie_uuid: uuid, status: :in_progress, worker: worker, origin_url: "/f/1.mkv")
    %{task: task, worker: worker}
  end

  test "transcoding started proper", %{task: task, worker: worker} do
    with_mocks([{System, [:passthrough], [cmd: fn _, _, _ -> {"", 0} end]}]) do
      res = Workers.Transcoding.call(worker, task)
      assert res == :ok
      task = Master.Repo.reload(task)
      assert task.status == :in_progress
    end
  end

  test "transcoding not started", %{task: task, worker: worker} do
    with_mocks([{System, [:passthrough], [cmd: fn _, _, _ -> {"fake error", 1} end]}]) do
      res = Workers.Transcoding.call(worker, task)
      assert res == :error
      task = Master.Repo.reload(task)
      assert task.status == :new
    end
  end
end

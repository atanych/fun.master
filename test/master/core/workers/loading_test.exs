defmodule Workers.LoadingTest do
  use MasterWeb.ConnCase

  test "status ready" do
    server =
      insert(:server,
        name: "def_1",
        total_space: 100,
        available_space: 100,
        reserved_space: Ext.Config.get([Servers.ChangeReserved, :default_reserve])
      )

    worker = insert(:worker, ip: "192.168.1.1", status: :busy)
    task = insert(:task, server_id: server.id, movie_uuid: Ecto.UUID.generate(), status: :loading, worker_id: worker.id)
    task |> Master.Repo.preload(:server) |> Workers.Loading.call()
    task = Master.Repo.reload(task)
    server = Master.Repo.reload(server)
    assert task.status == :done
    assert server.reserved_space == 0
  end
end

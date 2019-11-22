defmodule Tasks.ServerQueryTest do
  use MasterWeb.ConnCase

  setup_with_mocks([{Ext.Config, [:passthrough], [get: fn :self_name -> "def_1" end]}]) do
    :ok
  end

  describe ".call" do
    test "if task have self master" do
      self_server = insert(:server, name: "def_1", total_space: 100, available_space: 100)
      server = insert(:server, name: "def_2", total_space: 100, available_space: 100)
      self_uuid = Ecto.UUID.generate()
      insert(:task, server_id: self_server.id, movie_uuid: self_uuid)
      insert(:task, server_id: server.id, movie_uuid: Ecto.UUID.generate())
      tasks = Master.Task |> Tasks.ServerQuery.call() |> Master.Repo.all()
      assert length(tasks) == 1
      assert tasks |> List.first() |> Map.get(:movie_uuid) == self_uuid
    end

    test "if task don't have self master" do
      server_1 = insert(:server, name: "def_2", total_space: 100, available_space: 100)
      server_2 = insert(:server, name: "def_2", total_space: 100, available_space: 100)
      insert(:task, server_id: server_1.id, movie_uuid: Ecto.UUID.generate())
      insert(:task, server_id: server_2.id, movie_uuid: Ecto.UUID.generate())
      tasks = Master.Task |> Tasks.ServerQuery.call() |> Master.Repo.all()
      assert tasks == []
    end
  end
end

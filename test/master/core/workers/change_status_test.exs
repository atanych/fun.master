defmodule Workers.ChangeStatusTest do
  use MasterWeb.ConnCase

  describe ".call" do
    test "change status to :busy, if max_task = 1" do
      worker = insert(:worker, ip: "192.168.1.1", status: :ready, max_tasks: 1)
      worker = Workers.ChangeStatus.call(worker, :busy)
      assert %{status: :busy, tasks_in_progress: 1} = worker
    end

    test "change status to :busy, if max_task = 2" do
      worker = insert(:worker, ip: "192.168.1.1", status: :ready, max_tasks: 2)
      worker = Workers.ChangeStatus.call(worker, :busy)
      assert %{status: :ready, tasks_in_progress: 1} = worker

      worker = Workers.ChangeStatus.call(worker, :busy)
      assert %{status: :busy, tasks_in_progress: 2} = worker
    end

    test "raise error if change status to :busy, if max_task = 2, tasks_in_progress == 2" do
      worker = insert(:worker, ip: "192.168.1.1", status: :ready, max_tasks: 2, tasks_in_progress: 2)

      assert_raise(RuntimeError, ~r/Error if ChangeStatus to :busy worker -/, fn ->
        Workers.ChangeStatus.call(worker, :busy)
      end)
    end

    test "change status to :ready, if max_task = 1, tasks_in_progress = 1" do
      worker = insert(:worker, ip: "192.168.1.1", status: :ready, max_tasks: 1, tasks_in_progress: 1)
      worker = Workers.ChangeStatus.call(worker, :ready)
      assert %{status: :ready, tasks_in_progress: 0} = worker
    end

    test "change status to :ready, if max_task = 2" do
      worker = insert(:worker, ip: "192.168.1.1", status: :ready, max_tasks: 2, tasks_in_progress: 2)
      worker = Workers.ChangeStatus.call(worker, :ready)
      assert %{status: :ready, tasks_in_progress: 1} = worker

      worker = Workers.ChangeStatus.call(worker, :ready)
      assert %{status: :ready, tasks_in_progress: 0} = worker
    end

    test "raise error if change status to :ready, if max_task = 2, tasks_in_progress == 0" do
      worker = insert(:worker, ip: "192.168.1.1", status: :ready, max_tasks: 2, tasks_in_progress: 0)

      assert_raise(RuntimeError, ~r/Error if ChangeStatus to :ready worker -/, fn ->
        Workers.ChangeStatus.call(worker, :ready)
      end)
    end
  end
end

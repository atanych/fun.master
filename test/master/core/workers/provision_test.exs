defmodule WorkersProvisionTest do
  use MasterWeb.ConnCase

  test "setup deps" do
    with_mocks([{Ops.Shells.Exec, [], [call: fn _, _, _ -> "" end]}]) do
      worker = insert(:worker, ip: "192.168.1.1", status: :new)
      Workers.Provision.call()
      worker = Master.Repo.reload(worker)
      assert worker.status == :ready
    end
  end

  test "no workers check" do
    with_mocks([{Ops.Shells.Exec, [], [call: fn _, _, _ -> "" end]}]) do
      Workers.Provision.call()
      refute called(Ops.Shells.Exec.call(:_, :_, :_))
    end
  end
end

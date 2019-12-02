defmodule Workers.WorkerTest do
  use MasterWeb.ConnCase

  test "handle_info(:run_activity)" do
    with_mocks([{Workers.Provision, [], [call: fn -> "" end]}]) do
      Workers.Worker.handle_info(:run_activity, [])
      assert called(Workers.Provision.call())
    end
  end
end

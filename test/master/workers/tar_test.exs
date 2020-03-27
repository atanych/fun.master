defmodule Workers.TarTest do
  use MasterWeb.ConnCase

  test "handle_info(:run_activity)" do
    with_mocks([
      {Tasks.Tar, [], [call: fn _ -> "" end]}
    ]) do
      insert(:task, status: :ready_to_tar, server: insert(:server, name: "m1"))
      Workers.Tar.handle_info(:run_activity, [])
      assert_called(Tasks.Tar.call(:_))
    end
  end
end

defmodule Workers.TasksTest do
  use MasterWeb.ConnCase

  test "handle_info(:run_activity)" do
    with_mocks([
      {Tasks.ProcessLoading, [], [call: fn -> "" end]},
      {Tasks.ProcessInProgress, [], [call: fn -> "" end]},
      {Tasks.ProcessNew, [], [call: fn -> "" end]}
    ]) do
      Workers.Task.handle_info(:run_activity, [])
      assert called(Tasks.ProcessLoading.call())
      assert called(Tasks.ProcessInProgress.call())
      assert called(Tasks.ProcessNew.call())
    end
  end
end

defmodule Workers.GetTranscodingStatusTest do
  use MasterWeb.ConnCase

  test "status ready" do
    status = Workers.GetTranscodingStatus.call("")
    assert status == "ready"
  end
end

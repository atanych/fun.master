defmodule Workers.TranscodingTest do
  use MasterWeb.ConnCase

  test "transcoding" do
    res = Workers.Transcoding.call("", "")
    assert is_nil(res)
  end
end

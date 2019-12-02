defmodule Servers.GetSpaceTest do
  use MasterWeb.ConnCase

  test "get disks space" do
    with_mocks([
      {System, [:passthrough],
       [
         cmd: fn _, _ ->
           {"Filesystem     Size   Used  Avail Capacity iused               ifree %iused  Mounted on\n/dev/disk1s1  233Gi  103Gi  127Gi    45% 3075447 9223372036851700360    0%   /\n",
            0}
         end
       ]},
      {File, [:passthrough], [ls!: fn _ -> ["d1"] end]}
    ]) do
      spaces = Servers.GetSpace.call()
      assert spaces == [%{available_space: 127, dir: "d1", total_space: 233}]
    end
  end
end

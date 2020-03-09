defmodule Workers.BuildSshArgsTest do
  use MasterWeb.ConnCase

  setup do
    %{worker: insert(:worker, ip: "192.168.1.1", status: :ready)}
  end

  describe ".call" do
    test "ssh args", %{worker: worker} do
      args = Workers.BuildSshArgs.call(worker, ["rm", "-r", "/home/origin/"])

      assert args == [
               "-o ServerAliveInterval=5",
               "-o ServerAliveCountMax=2",
               "-oStrictHostKeyChecking=no",
               "-i",
               "devops/workers/workers.key",
               "root@192.168.1.1",
               "rm",
               "-r",
               "/home/origin/"
             ]
    end

    test "scp args", %{worker: worker} do
      args = Workers.BuildSshArgs.call(worker, ["/home/origin/", "/m1/d1/"], :scp)

      assert args == [
               "-o ServerAliveInterval=5",
               "-o ServerAliveCountMax=2",
               "-oStrictHostKeyChecking=no",
               "-i",
               "devops/workers/workers.key",
               "-r",
               "root@192.168.1.1:/home/origin/",
               "/m1/d1/"
             ]
    end
  end
end

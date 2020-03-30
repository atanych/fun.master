defmodule Tasks.TarTest do
  use MasterWeb.ConnCase

  test ".call (success)" do
    with_mocks([{Ext.System, [], [cmd!: fn _, _ -> "" end]}]) do
      task =
        insert(:task,
          movie_uuid: "9bbb2be5-9309-46de-bc8e-31e15ad18032",
          url: "m1/disk2/08/9bbb2be5-9309-46de-bc8e-31e15ad18032/master.m3u8"
        )

      Tasks.Tar.call(task)

      assert_called(
        Ext.System.cmd!("tar", [
          "czf",
          "m1/disk2/08/9bbb2be5-9309-46de-bc8e-31e15ad18032.tar",
          "m1/disk2/08/9bbb2be5-9309-46de-bc8e-31e15ad18032"
        ])
      )

      assert_called(Ext.System.cmd!("rm", ["-R", "m1/disk2/08/9bbb2be5-9309-46de-bc8e-31e15ad18032"]))

      task = Master.Repo.reload(task)
      assert task.status == :done
    end
  end

  test ".call (error)" do
    with_mocks([{Ext.System, [], [cmd!: fn _, _ -> raise "error" end]}]) do
      task =
        insert(:task,
          movie_uuid: "9bbb2be5-9309-46de-bc8e-31e15ad18032",
          url: "m1/disk2/08/9bbb2be5-9309-46de-bc8e-31e15ad18032/master.m3u8"
        )

      Tasks.Tar.call(task)

      task = Master.Repo.reload(task)
      assert task.status == :new
    end
  end
end

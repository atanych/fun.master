defmodule Servers.ChangeReservedTest do
  use MasterWeb.ConnCase

  describe ".call" do
    test "increase if reserved nil" do
      server = insert(:server, name: "def_1", total_space: 100, available_space: 100)
      server = Servers.ChangeReserved.call(server, :increase)
      assert server.reserved_space == Ext.Config.get([Servers.ChangeReserved, :default_reserve])
    end

    test "increase if reserved not nil" do
      server = insert(:server, name: "def_1", total_space: 100, available_space: 100, reserved_space: 10)
      server = Servers.ChangeReserved.call(server, :increase)
      assert server.reserved_space == 10 + Ext.Config.get([Servers.ChangeReserved, :default_reserve])
    end

    test "decrease if reserved nil" do
      server = insert(:server, name: "def_1", total_space: 100, available_space: 100)
      server = Servers.ChangeReserved.call(server, :decrease)
      assert server.reserved_space == 0
    end

    test "decrease if reserved not nil" do
      server = insert(:server, name: "def_1", total_space: 100, available_space: 100, reserved_space: 20)
      server = Servers.ChangeReserved.call(server, :decrease)
      assert server.reserved_space == 20 - Ext.Config.get([Servers.ChangeReserved, :default_reserve])
    end
  end
end

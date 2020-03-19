defmodule Servers.ChangeReserved do
  @moduledoc false
  require Logger

  @default_reserve Ext.Config.get([__MODULE__, :default_reserve])

  def call(server_id, type) do
    {:ok, server} =
      Master.Repo.transaction(fn ->
        server = Master.Server |> Master.Repo.lock_for_update() |> Master.Repo.get(server_id)
        Master.Repo.save!(server, %{reserved_space: calc_value(server.reserved_space, type)})
      end)

    server
  end

  def calc_value(value, :increase), do: value + @default_reserve

  def calc_value(0, :decrease) do
    Logger.error("You can't decrease from zero")
    0
  end

  def calc_value(value, :decrease), do: value - @default_reserve
end

defmodule Servers.ChangeReserved do
  @moduledoc false
  require Logger

  @default_reserve Ext.Config.get([__MODULE__, :default_reserve])

  def call(server, type), do: Master.Repo.save!(server, %{reserved_space: calc_value(server.reserved_space, type)})

  def calc_value(value, :increase), do: value + @default_reserve

  def calc_value(0, :decrease) do
    Logger.error("You can't decrease from zero")
    0
  end

  def calc_value(value, :decrease), do: value - @default_reserve
end

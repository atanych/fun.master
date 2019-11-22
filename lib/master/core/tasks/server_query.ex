defmodule Tasks.ServerQuery do
  @moduledoc false

  def call(query),
    do: query |> Master.Repo.join(:server) |> Master.Repo.where(%{server: %{name: Ext.Config.get(:self_name)}})
end

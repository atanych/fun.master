defmodule Servers.GetSpace do
  @moduledoc false
  require Logger
  require IEx

  def call do
    "content"
    |> File.ls!()
    |> Enum.map(fn dir ->
      {space, 0} = System.cmd("df", ["#{if Mix.env() in [:dev, :test], do: "-h", else: "-BG"}", "content/#{dir}"])

      space =
        space |> String.trim("\n") |> String.split("\n") |> List.last() |> String.split(" ") |> Enum.reject(&(&1 == ""))

      %{dir: dir, total_space: space |> Enum.at(1) |> to_int(), available_space: space |> Enum.at(3) |> to_int()}
    end)
    |> Enum.filter(&(&1.available_space > Ext.Config.get([__MODULE__, :min_disk_space])))
  end

  def to_int(space), do: space |> String.replace(~r/[^\d]/, "") |> String.to_integer()
end

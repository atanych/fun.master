defmodule Workers.GetTranscodingStatus do
  @moduledoc false
  require IEx
  require Logger

  def call(task) do
    Logger.warn("GetTranscodingStatus task - #{inspect(task)}")
    "ready"
  end
end

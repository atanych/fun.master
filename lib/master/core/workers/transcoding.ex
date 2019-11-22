defmodule Workers.Transcoding do
  @moduledoc false
  require IEx
  require Logger

  def call(worker, _task) do
    Logger.warn("START TRANSCODING WORKER - #{inspect(worker)}")
    nil
  end
end

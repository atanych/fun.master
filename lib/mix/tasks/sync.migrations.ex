defmodule Mix.Tasks.Sync.Migrations do
  @moduledoc false
  use Mix.Task

  def run(_) do
    System.cmd("cp", ["-r", "../fun.engine/priv/master_repo/migrations", "priv/repo"])
  end
end

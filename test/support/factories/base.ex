defmodule Factories.Base do
  @moduledoc false
  use ExMachina.Ecto, repo: Master.Repo
  use Factories.{Server, Worker, Task}
end

defmodule Mix.Tasks.DeleteBeforeRestarting do
  @moduledoc false
  use Mix.Task
  require IEx
  require Ecto.Query

  def run([limit]) do
    Enum.each([:postgrex, :ecto], &Application.ensure_all_started/1)
    Master.Repo.start_link()

    Master.Task
    |> Tasks.ServerQuery.call()
    |> Master.Repo.where(status: :delete_before_restarting)
    |> Ecto.Query.limit(^limit)
    |> Master.Repo.order_by(asc: :id)
    |> Master.Repo.all()
    |> Enum.each(fn task ->
      if task.url, do: task.url |> String.split("/") |> Enum.drop(-1) |> Enum.join("/") |> File.rm_rf!()
      Master.Repo.save(task, %{status: :restarting})
      if rem(task.id, 100) == 0, do: IO.puts("Handled id - #{task.id}")
    end)
  end
end

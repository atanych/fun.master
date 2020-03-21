defmodule Mix.Tasks.ProvisionWorkers do
  @moduledoc false
  use Mix.Task
  require IEx

  def run([]), do: do_run(%{status: {"!=", 1}})
  def run([ids]), do: do_run(%{id: String.split(ids, ",")})

  def do_run(conditions) do
    Enum.each([:postgrex, :ecto], &Application.ensure_all_started/1)
    Master.Repo.start_link

    Master.Worker
    |> Master.Repo.where(conditions)
    |> Master.Repo.order_by(asc: :id)
    |> Master.Repo.all()
    |> Enum.each(fn worker ->
      args = [
        "-i",
        "localhost",
        "devops/workers/generate_hosts.yml",
        "--extra-vars",
        "host_ip=#{worker.ip}"
      ]

      "ansible-playbook"
      |> System.find_executable()
      |> Ops.Shells.Exec.call(args, [{:line, 4_096}])

      # start provision worker
      args = ["-i", "tmp/hosts", "devops/workers/provision.yml"]

      "ansible-playbook"
      |> System.find_executable()
      |> Ops.Shells.Exec.call(args, [{:line, 4_096}])
    end)
  end
end

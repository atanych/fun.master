defmodule Workers.Provision do
  @moduledoc false
  require IEx

  def call do
    {:ok, worker} =
      Master.Repo.transaction(fn ->
        Master.Worker
        |> Master.Repo.lock_for_update()
        |> Master.Repo.where(status: :new)
        |> Master.Repo.first()
        |> set_status_provision()
      end)

    if worker do
      # generate file tmp/hosts
      args = ["-i", "localhost", "devops/workers/generate_hosts.yml", "--extra-vars", "host_ip=#{worker.ip}"]
      "ansible-playbook" |> System.find_executable() |> Ops.Shells.Exec.call(args, [{:line, 4_096}])

      # start provision worker
      args = ["-i", "tmp/hosts", "devops/workers/provision.yml"]
      "ansible-playbook" |> System.find_executable() |> Ops.Shells.Exec.call(args, [{:line, 4_096}])

      Master.Repo.save!(worker, %{status: :ready})
    end
  end

  def set_status_provision(nil), do: nil
  def set_status_provision(worker), do: Master.Repo.save!(worker, %{status: :provisioning})
end

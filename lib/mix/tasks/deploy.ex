defmodule Mix.Tasks.Deploy do
  @moduledoc false
  use Mix.Task
  require IEx

  def run([env_name]), do: run([env_name, Ops.Utils.Git.lookup_image_tag()])

  def run([env_name, tag]) do
    HTTPoison.start()
    config_path = "devops/servers/deploy/envs/#{env_name}.yml"
    config = File.cwd!() |> Path.join(config_path) |> YamlElixir.read_from_file!() |> Ext.Utils.Base.to_atom()
    context = %{env_name: env_name, tag: tag, db_hostname: config.db_hostname, db_port: config.db_port}
    config |> Map.get(:masters, []) |> Enum.each(&deploy(&1, context))
  end

  def deploy(master, %{env_name: env_name, tag: tag, db_hostname: db_hostname, db_port: db_port}) do
    Ops.Utils.Io.puts("Deploy master - '#{master.name}'. Environment=#{env_name}. Image=#{tag}")

    # Find or create build
    Ops.Deploy.FindOrCreateBuild.call(%{tag: tag})

    # generate file tmp/hosts
    vars = [
      "env_name=#{env_name}",
      "master_name=#{master.name}",
      "master_ip=#{master.ip}",
      "db_hostname=#{db_hostname}",
      "db_port=#{db_port}"
    ]

    args = ["-i", "localhost", "devops/servers/deploy/generate_configs.yml", "--extra-vars", Enum.join(vars, " ")]
    "ansible-playbook" |> System.find_executable() |> Ops.Shells.Exec.call(args, [{:line, 4_096}])

    vars = [
      "tag=#{tag}",
      "repository=#{Ops.Utils.Config.lookup_image_repository()}",
      "docker_user=#{Ops.Utils.Config.settings()[:docker][:username]}",
      "docker_pass=#{Ops.Utils.Config.settings()[:docker][:password]}"
    ]

    # deploy host
    args = ["-i", "tmp/deploy_host", "devops/servers/deploy/playbook.yml", "--extra-vars", Enum.join(vars, " ")]
    "ansible-playbook" |> System.find_executable() |> Ops.Shells.Exec.call(args, [{:line, 4_096}])
  end
end

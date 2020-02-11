defmodule Master.Repo.Migrations.AddColOriginServerIpToTaksk do
  use Ecto.Migration

  def change do
    alter table :tasks do
      add :origin_server_ip, :string, description: "IP of origin server"
    end
  end
end

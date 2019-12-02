defmodule Master.Repo.Migrations.AddColUrlToTasks do
  use Ecto.Migration

  def change do
    alter table :tasks do
      add :url, :string, description: "Transcode movie url"
    end
  end
end

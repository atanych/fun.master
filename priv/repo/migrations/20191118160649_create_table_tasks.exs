defmodule Master.Repo.Migrations.CreateTableTasks do
  use Ecto.Migration

  def change do
    create table(:tasks) do
      add(:movie_uuid, :uuid)
      add(:origin_url, :string)
      add(:status, :smallint, default: 0)
      add(:worker_id, references(:workers))
      add(:server_id, references(:servers))
      timestamps(type: :timestamptz)
    end
  end
end

defmodule Master.Repo.Migrations.CreateTableUploadTasks do
  use Ecto.Migration

  def change do
    create table(:upload_tasks) do
      add(:movie_uuid, :uuid)
      add(:url, :string)
      add(:status, :smallint, default: 0)
      add(:cdn_info, :map, default: %{})
      add(:server_id, references(:servers))
      timestamps(type: :timestamptz)
    end
  end
end

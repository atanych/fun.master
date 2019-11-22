defmodule Master.Repo.Migrations.CreateTableWorkers do
  use Ecto.Migration

  def change do
    create table(:workers) do
      add(:ip, :string)
      add(:status, :smallint)
      timestamps(type: :timestamptz)
    end

    create(index(:workers, [:status]))
  end
end

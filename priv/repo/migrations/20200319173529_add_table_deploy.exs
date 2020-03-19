defmodule Master.Repo.Migrations.AddTableDeploy do
  use Ecto.Migration

  def change do
    create table(:deploy) do
      add(:status, :smallint, default: 0)
    end
  end
end

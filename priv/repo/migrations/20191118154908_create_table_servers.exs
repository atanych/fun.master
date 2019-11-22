defmodule Master.Repo.Migrations.CreateTableServers do
  use Ecto.Migration

  def change do
    create table(:servers) do
      add(:name, :string)
      add(:total_space, :integer, default: 0, description: "Total space in Gb")
      add(:available_space, :integer, default: 0, description: "Available space in Gb")
      timestamps(type: :timestamptz)
    end
  end
end

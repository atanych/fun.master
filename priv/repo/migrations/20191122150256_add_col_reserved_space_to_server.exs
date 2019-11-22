defmodule Master.Repo.Migrations.AddColReservedSpaceToServer do
  use Ecto.Migration

  def change do
    alter table :servers do
      add :reserved_space, :integer, default: 0, description: "Reserved space in Gb"
    end
  end
end

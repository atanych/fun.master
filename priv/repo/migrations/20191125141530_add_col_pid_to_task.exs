defmodule Master.Repo.Migrations.AddColPidToTask do
  use Ecto.Migration

  def change do
    alter table :tasks do
      add :pid, :string, description: "ID of loading task"
    end

    create(index(:tasks, [:status]))
  end
end

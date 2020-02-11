defmodule Master.Repo.Migrations.AddColsForTasksInWorkers do
  use Ecto.Migration

  def change do
    alter table(:workers) do
      add(:max_tasks, :integer, default: 0)
      add(:tasks_in_progress, :integer, default: 0)
    end
  end
end

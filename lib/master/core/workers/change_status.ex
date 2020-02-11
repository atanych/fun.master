defmodule Workers.ChangeStatus do
  @moduledoc false

  def call(worker, type) do
    count_in_progress = calc_count_in_progress(worker, type)
    status = if worker.max_tasks <= count_in_progress, do: :busy, else: :ready
    Master.Repo.save!(worker, %{status: status, tasks_in_progress: count_in_progress})
  end

  def calc_count_in_progress(worker, :busy),
    do:
      if(worker.max_tasks > worker.tasks_in_progress,
        do: worker.tasks_in_progress + 1,
        else: raise("Error if ChangeStatus to :busy worker - #{inspect(worker)}")
      )

  def calc_count_in_progress(worker, :ready),
    do:
      if(worker.tasks_in_progress > 0,
        do: worker.tasks_in_progress - 1,
        else: raise("Error if ChangeStatus to :ready worker - #{inspect(worker)}")
      )
end

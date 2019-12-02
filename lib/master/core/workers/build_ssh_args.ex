defmodule Workers.BuildSshArgs do
  @moduledoc false

  @spec call(Master.Worker.t(), List.t(), Atom.t()) :: List.t()
  def call(worker, args, type \\ :ssh)
  def call(worker, args, :ssh), do: common_args() ++ ["root@#{worker.ip}"] ++ args

  def call(worker, [head | tail], :scp), do: common_args() ++ ["-r", "root@#{worker.ip}:#{head}"] ++ tail

  def common_args, do: ["-oStrictHostKeyChecking=no", "-i", "devops/workers/workers.key"]
end

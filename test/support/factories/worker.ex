defmodule Factories.Worker do
  @moduledoc false
  defmacro __using__(_opts) do
    quote do
      def worker_factory do
        %Master.Worker{}
      end
    end
  end
end

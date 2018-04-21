defmodule Eventizer do
  @moduledoc """
  Simple PubSub library.
  """

  require Logger

  def subscribe(topic, {_module, _function} = handler) do
    {:ok, _} = Registry.register(Eventizer.Dispatcher, topic, handler)
    :ok
  end

  def publish(topic, event) do
    :ok = Registry.dispatch(Eventizer.Dispatcher, topic, fn entries ->
      for {_pid, {module, function}} <- entries do
        try do
          apply(module, function, [event])
        catch
          kind, reason ->
            formatted = Exception.format(kind, reason, System.stacktrace())
            Logger.error "Eventizer dispatch failed for topic #{inspect topic}, handler #{inspect {module, function}} end event #{inspect event} with #{formatted}"
        end
      end
    end)
  end
end

defmodule Eventizer do
  @moduledoc """
  Simple PubSub library.
  """

  require Logger

  defmacro __using__(_opts) do
    quote do
      @behaviour Eventizer.Handler

      Module.register_attribute __MODULE__, :event_handler, accumulate: true

      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(env) do
    handlers = Module.get_attribute env.module, :event_handler
    quote do
      @doc false
      @impl true
      def subscribe_eventizer_handlers do
        Enum.each(unquote(handlers), fn {topic, handler} ->
          :ok = unquote(__MODULE__).subscribe(topic, {unquote(env.module), handler})
        end)
        :ok
      end
    end
  end

  def load_handlers(modules) do
    Enum.each(modules, fn module ->
      :ok = module.subscribe_eventizer_handlers()
    end)
    :ok
  end

  def subscribe(topic, {_module, _function} = handler) do
    {:ok, _} = Registry.register(Eventizer.Dispatcher, topic, handler)
    :ok
  end

  def publish(topic, event) do
    :ok =
      Registry.dispatch(Eventizer.Dispatcher, topic, fn entries ->
        for {_pid, {module, function}} <- entries do
          try do
            apply(module, function, [event])
          catch
            kind, reason ->
              formatted = Exception.format(kind, reason, System.stacktrace())

              Logger.error(
                "Eventizer dispatch failed for topic #{inspect(topic)}, handler #{
                  inspect({module, function})
                } end event #{inspect(event)} with #{formatted}"
              )
          end
        end
      end)
  end
end

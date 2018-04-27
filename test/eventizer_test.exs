defmodule EventizerTest do
  use ExUnit.Case
  doctest Eventizer

  import Mox

  setup :verify_on_exit!

  defmodule MacroHandlerMock do
    use Eventizer

    @event_handler {:bar, :handle}

    def handle(%{pid: pid} = event) do
      send pid, event
    end
  end

  test "subscribe registers a handler" do
    assert :ok = Eventizer.subscribe(:foo, {IO, :inspect})
    assert [{_, {IO, :inspect}}] = Registry.lookup(Eventizer.Dispatcher, :foo)
  end

  test "publish publishes the event payload" do
    expect(Eventizer.HandlerMock, :handle, fn event ->
      assert event == %{some: :event}
    end)

    assert :ok = Eventizer.subscribe(:foo, {Eventizer.HandlerMock, :handle})
    assert :ok = Eventizer.publish(:foo, %{some: :event})
  end

  test "publish publishes event for macro subscribed handler" do
    Eventizer.load_handlers([MacroHandlerMock])
    assert :ok = Eventizer.publish(:bar, %{some: :event, pid: self()})
    assert_receive %{some: :event}
  end
end

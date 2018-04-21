defmodule EventizerTest do
  use ExUnit.Case
  doctest Eventizer

  import Mox

  setup :verify_on_exit!

  test "subscribe registers a handler" do
    assert :ok = Eventizer.subscribe(:foo, {IO, :inspect})
    assert [{_, {IO, :inspect}}] = Registry.lookup(Eventizer.Dispatcher, :foo)
  end

  test "publish publishes the event payload" do
    expect(Eventizer.HandlerMock, :handle, fn event ->
      assert event == %{some: :event} end)

    assert :ok = Eventizer.subscribe(:foo, {Eventizer.HandlerMock, :handle})
    assert :ok = Eventizer.publish(:foo, %{some: :event})
  end
end

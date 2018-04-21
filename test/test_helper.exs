ExUnit.start()

defmodule Eventizer.TestHandler do
  @callback handle(term()) :: term()
end

Mox.defmock(Eventizer.HandlerMock, for: Eventizer.TestHandler)

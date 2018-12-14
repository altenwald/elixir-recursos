defmodule TcpCliParallel do
  def concurrent_send(port, num \\ 5) do
    f = fn(i) -> TcpCli.send(port, "i=#{inspect i}") end
    1..num
    |> Task.async_stream(f, timeout: 10_000)
    |> Enum.to_list()
  end
end

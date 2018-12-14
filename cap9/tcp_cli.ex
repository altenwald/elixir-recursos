defmodule TcpCli do
  def send(port, msg) do
    opts = [active: true]
    {:ok, socket} = :gen_tcp.connect({127,0,0,1}, port, opts)
    :gen_tcp.send(socket, msg)
    receive do
      {:tcp, ^socket, msg_srv} ->
        IO.puts "Retornado #{inspect self()}: #{msg_srv}"
      any ->
        IO.puts "Mensaje no reconocido: #{inspect any}"
    end
    :gen_tcp.close socket
  end
end

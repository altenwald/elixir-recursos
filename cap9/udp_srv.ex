defmodule UdpSrv do

  def start(port) do
    {:ok, spawn(__MODULE__, :init, [port])}
  end

  def init(port) do
    IO.puts "init #{port}"
    {:ok, socket} = :gen_udp.open(port)
    loop(socket)
  end

  def loop(socket) do
    IO.puts "waiting for input info... #{inspect socket}"
    receive do
      :stop ->
        :gen_udp.close(socket)
      {:udp, socket, ip, port, msg} ->
        IO.puts "recibido(#{inspect ip}): #{inspect msg}"
        :gen_udp.send socket, ip, port, "recibido"
        loop(socket)
    end
  end
end

defmodule HttpSrv do
  use GenServer

  @resp """
        HTTP/1.1 200 OK
        Content-Length: 2
        Content-Type: text/plain

        OK
        """
  @accept_timeout 1_000

  def start(port) do
    GenServer.start __MODULE__, [port], name: __MODULE__
  end

  @impl true
  def init([port]) do
    opts = [reuseaddr: true, active: :once, packet: :http]
    {:ok, socket} = :gen_tcp.listen(port, opts)
    GenServer.cast self(), :accept
    {:ok, socket}
  end

  @impl true
  def handle_cast(:accept, socket) do
    case :gen_tcp.accept(socket, @accept_timeout) do
      {:ok, sock_cli} ->
        IO.puts "conexión entrante: #{inspect sock_cli}"
        task = Task.async(fn -> worker_loop sock_cli end)
        :gen_tcp.controlling_process sock_cli, task.pid
        :inet.setopts sock_cli, active: true
        :inet.setopts socket, active: :once
      {:error, :timeout} ->
        :ok
    end
    GenServer.cast self(), :accept
    {:noreply, socket}
  end

  @impl true
  def terminate(_reason, socket) do
    :gen_tcp.close(socket)
  end

  @impl true
  def handle_info(_msg, socket) do
    # ignore unformatted messages
    {:noreply, socket}
  end

  def worker_loop(socket) do
    receive do
      {:http, ^socket, :http_eoh} ->
        IO.puts "Fin cabeceras (http_eoh)"
        :inet.setopts socket, [packet: :raw]
        :gen_tcp.send socket, @resp
        :gen_tcp.close socket
      {:http, ^socket, {:http_request, method, uri, _}} ->
        IO.puts "Recibido (http) #{inspect self()}: " <>
                "#{method} #{inspect uri}"
        worker_loop socket
      {:http, ^socket, {:http_header, _, name, _, _val}} ->
        IO.puts "Recibido (http) #{inspect self()}: " <>
                "header #{name}"
        worker_loop socket
      {:tcp_closed, ^socket} ->
        IO.puts "Finalizado"
        :gen_tcp.close socket
      any ->
        IO.puts "Mensaje no reconocido: #{inspect any}"
        :gen_tcp.close socket
    end
  end
end

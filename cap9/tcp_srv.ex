defmodule TcpSrv do
  use GenServer

  @accept_timeout 1_000

  def start(port) do
    GenServer.start __MODULE__, [port], name: __MODULE__
  end

  @impl true
  def init([port]) do
    opts = [reuseaddr: true, active: false]
    {:ok, socket} = :gen_tcp.listen(port, opts)
    GenServer.cast self(), :accept
    {:ok, socket}
  end

  @impl true
  def handle_cast(:accept, socket) do
    case :gen_tcp.accept(socket, @accept_timeout) do
      {:ok, sock_cli} ->
        task = Task.async(fn -> worker_loop sock_cli end)
        :gen_tcp.controlling_process sock_cli, task.pid
        :inet.setopts sock_cli, active: true
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
      {:tcp, ^socket, msg} ->
        IO.puts "Recibido #{inspect self()}: #{inspect msg}"
        IO.puts "Espera 5 segundos y entonces responde"
        Process.sleep 5_000
        salida = "eco: #{msg}"
        :gen_tcp.send socket, salida
        worker_loop socket
      {:tcp_closed, ^socket} ->
        IO.puts "Finalizado."
      any ->
        IO.puts "Mensaje no reconocido: #{inspect any}"
    end
  end
end

defmodule Estadistica do
  use GenServer

  defmodule State do
    defstruct cuenta: 0,
              sumatorio: 0,
              media: 0,
              max: 0,
              min: nil
  end

  alias Estadistica.State

  def start_link do
    GenServer.start_link __MODULE__, [], name: __MODULE__
  end

  def stop do
    GenServer.stop __MODULE__
  end

  def get(name) do
    GenServer.call(__MODULE__, name)
  end

  def add(num) do
    GenServer.cast(__MODULE__, {:num, num})
  end

  @impl true
  def init([]) do
    {:ok, %State{}}
  end

  @impl true
  def handle_call(:sum, _from, state) do
    {:reply, state.sumatorio, state}
  end

  @impl true
  def handle_call(:avg, _from, state) do
    {:reply, state.media, state}
  end

  @impl true
  def handle_call(:max, _from, state) do
    {:reply, state.max, state}
  end

  @impl true
  def handle_call(:min, _from, state) do
    {:reply, state.min, state}
  end

  @impl true
  def handle_cast({:num, num}, state) do
    cuenta = state.cuenta + 1
    sumatorio = state.sumatorio + num
    media = (sumatorio + num) / cuenta
    state = %State{state | cuenta: cuenta,
                           sumatorio: sumatorio,
                           media: media,
                           max: max(state.max, num),
                           min: min(state.min, num)}
    {:noreply, state}
  end
end

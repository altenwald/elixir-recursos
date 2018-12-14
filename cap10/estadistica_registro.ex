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

  defp via(stats_name) do
    {:via, Registry, {Estadistica.Registry, stats_name}}
  end

  def start_link(stats_name) do
    GenServer.start_link __MODULE__, [], name: via(stats_name)
  end

  def stop(stats_name) do
    GenServer.stop via(stats_name)
  end

  def get(stats_name, name) do
    GenServer.call(via(stats_name), name)
  end

  def add(stats_name, num) do
    GenServer.cast(via(stats_name), {:num, num})
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

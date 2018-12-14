defmodule User do
  use Call

  persist [:nombre, :edad]

  api :agrega, [nombre, edad], state do
    {:reply, :ok, state(state, nombre: nombre, edad: edad)}
  end

  api :obten, [], state do
    {:reply, state(state), state}
  end
end

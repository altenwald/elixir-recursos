defmodule QuickSort do
  def ordena([]), do: []
  def ordena([h]), do: [h]
  def ordena(lista) do
    {lista1, [pivote], lista2} = separa(lista)
    ordena(lista1) ++ [pivote] ++ ordena(lista2)
  end

  defp separa([pivote|t]) do
    {menor, mayor} = Enum.split_with t, &(&1 <= pivote)
    {menor, [pivote], mayor}
  end
end

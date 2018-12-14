defmodule MergeSort do
  def ordena([]), do: []
  def ordena([h]), do: [h]
  def ordena(lista) do
    {lista1, lista2} = separa(lista)
    mezcla(ordena(lista1), ordena(lista2))
  end

  defp separa(lista) do
    Enum.split lista, div(length(lista), 2)
  end

  defp mezcla([], lista), do: lista
  defp mezcla(lista, []), do: lista
  defp mezcla([h1|t1], [h2|_] = l2) when h1 <= h2 do
    [h1|mezcla(t1, l2)]
  end
  defp mezcla(l1, [h2|t2]) do
    [h2|mezcla(l1, t2)]
  end
end

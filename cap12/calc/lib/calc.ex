defmodule Calc do
  def main([op1, "+", op2]), do: IO.puts num(op1) + num(op2)
  def main([op1, "-", op2]), do: IO.puts num(op1) - num(op2)
  def main([op1, "*", op2]), do: IO.puts num(op1) * num(op2)
  def main([op1, "/", op2]), do: IO.puts num(op1) / num(op2)
  def main(_), do: IO.puts "Syntax: calc <n1> <+|-|*|/> <n2>"

  defp num(string) do
    {number, ""} = Float.parse(string)
    number
  end
end

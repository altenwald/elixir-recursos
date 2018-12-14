#!/usr/bin/env elixir

num = fn string ->
        {number, ""} = Float.parse(string)
        number
      end

case System.argv() do
  [op1, "+", op2] -> IO.puts num.(op1) + num.(op2)
  [op1, "-", op2] -> IO.puts num.(op1) - num.(op2)
  [op1, "*", op2] -> IO.puts num.(op1) * num.(op2)
  [op1, "/", op2] -> IO.puts num.(op1) / num.(op2)
  _ -> IO.puts "Syntax: calc <n1> <+|-|*|/> <n2>"
end

to_i = fn n -> String.to_integer(n) end

"./input.txt"
|> File.read!()
|> String.split("\n")
|> Enum.reduce({0, 0}, fn command, {x, y} ->
  case command do
    "forward " <> n -> {x + to_i.(n), y}
    "up " <> n -> {x, y - to_i.(n)}
    "down " <> n -> {x, y + to_i.(n)}
    _ -> {x, y}
  end
end)
|> (fn {x, y} -> x * y end).()
|> IO.puts()

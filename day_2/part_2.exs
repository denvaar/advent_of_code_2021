to_i = fn n -> String.to_integer(n) end

"./input.txt"
|> File.read!()
|> String.split("\n")
|> Enum.reduce({0, 0, 0}, fn command, {x, y, aim} ->
  case command do
    "forward " <> n -> {x + to_i.(n), y + to_i.(n) * aim, aim}
    "up " <> n -> {x, y, aim - to_i.(n)}
    "down " <> n -> {x, y, aim + to_i.(n)}
    _ -> {x, y, aim}
  end
end)
|> (fn {x, y, _aim} -> x * y end).()
|> IO.puts()

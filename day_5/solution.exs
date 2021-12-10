# My idea is to just use a giant map.
#
# Each key, value pair represents a
# coordinate and a count. The count
# increases as more and more lines
# include the point.

parse_point = fn point ->
  point
  |> String.split(",", trim: true)
  |> Enum.map(&String.to_integer/1)
end

parse_line = fn line ->
  [[x1, y1], [x2, y2]] =
    line
    |> String.split(" -> ", trim: true)
    |> Enum.map(&parse_point.(&1))

  [x1, y1, x2, y2]
end

points = fn
  [a, b] when a <= b -> a..b
  [a, b] -> b..a
end

points_along_line = fn a, b, acc ->
  Enum.zip_reduce(a, b, acc, fn x, y, acc ->
    count = Map.get(acc, {x, y}, 0)
    Map.put(acc, {x, y}, count + 1)
  end)
end

"./input.txt"
|> File.read!()
|> String.split("\n", trim: true)
|> Enum.map(&parse_line.(&1))
|> Enum.filter(fn [x1, y1, x2, y2] ->
  x1 == x2 or y1 == y2
end)
|> Enum.reduce(%{}, fn
  [x1, y1, x2, y2], acc when y1 == y2 ->
    Map.merge(
      acc,
      points_along_line.(
        points.([x1, x2]),
        Stream.cycle([y1]),
        acc
      )
    )

  [x1, y1, _x2, y2], acc ->
    Map.merge(
      acc,
      points_along_line.(
        Stream.cycle([x1]),
        points.([y1, y2]),
        acc
      )
    )
end)
|> Map.values()
|> Enum.filter(fn count -> count >= 2 end)
|> Enum.count()
|> IO.puts()

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

move_toward_target = fn current_point, target_point, history ->
  move_toward_target = fn {x, y}, {target_x, target_y}, acc, func ->
    x =
      cond do
        x == target_x -> x
        x < target_x -> x + 1
        x > target_x -> x - 1
      end

    y =
      cond do
        y == target_y -> y
        y < target_y -> y + 1
        y > target_y -> y - 1
      end

    if {x, y} == {target_x, target_y} do
      count = Map.get(acc, {x, y}, 0)
      Map.put(acc, {x, y}, count + 1)
    else
      count = Map.get(acc, {x, y}, 0)
      acc = Map.put(acc, {x, y}, count + 1)
      func.({x, y}, {target_x, target_y}, acc, func)
    end
  end

  count = Map.get(history, current_point, 0)
  history = Map.put(history, current_point, count + 1)

  move_toward_target.(
    current_point,
    target_point,
    history,
    move_toward_target
  )
end

"./input.txt"
|> File.read!()
|> String.split("\n", trim: true)
|> Enum.map(&parse_line.(&1))
|> Enum.reduce(%{}, fn [x1, y1, x2, y2], acc ->
  move_toward_target.({x1, y1}, {x2, y2}, acc)
end)
|> Map.values()
|> Enum.filter(fn count -> count >= 2 end)
|> Enum.count()
|> IO.puts()

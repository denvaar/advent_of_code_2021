binomial_coefficient = fn n ->
  # https://math.stackexchange.com/questions/593318/factorial-but-with-addition/593323
  div(n * n + n, 2)
end

crabs =
  "./input.txt"
  |> File.read!()
  |> String.trim("\n")
  |> String.split(",", trim: true)
  |> Enum.map(&String.to_integer/1)

possible_positions = Enum.min(crabs)..Enum.max(crabs)
start_value = {:infinity, %{}}

Enum.reduce(possible_positions, start_value, fn c1, {minimum, cache} ->
  cost = Map.get(cache, c1, Enum.sum(for c2 <- crabs, do: binomial_coefficient.(abs(c1 - c2))))

  {min(cost, minimum), Map.put(cache, c1, cost)}
end)
|> (fn {minimum, _} -> minimum end).()
|> IO.inspect(label: "Result")

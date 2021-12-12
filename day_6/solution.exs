cycle = fn
  0 -> 6
  n -> n - 1
end

grow = fn fishies ->
  spawn_count = Enum.count(fishies, &(&1 == 0))
  List.duplicate(8, spawn_count)
end

simulate_day = fn fishies ->
  newbs = Task.async(fn -> grow.(fishies) end)
  f = Enum.map(fishies, &cycle.(&1))

  f ++ Task.await(newbs, :infinity)
end

run = fn n_days, state ->
  run = fn
    0, fishies, _fn_binding ->
      fishies

    n_days, fishies, fn_binding ->
      fishies = simulate_day.(fishies)
      IO.inspect(fishies, limit: :infinity)
      fn_binding.(n_days - 1, fishies, fn_binding)
  end

  fishies = run.(n_days, state, run)

  Enum.count(fishies)
end

fishies =
  "./input.txt"
  |> File.read!()
  |> String.trim("\n")
  |> String.split(",", trim: true)
  |> Enum.map(&String.to_integer/1)

run.(80, fishies)
|> IO.inspect()

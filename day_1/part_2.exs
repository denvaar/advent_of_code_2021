numbs =
  "./input.txt"
  |> File.read!()
  |> String.split("\n")
  |> Enum.reduce([], fn n, acc ->
    case Integer.parse(n) do
      :error ->
        acc

      {numb, ""} ->
        [numb | acc]
    end
  end)
  |> Enum.reverse()

numbs
|> Enum.with_index()
|> Enum.reduce({1_000_000, 0}, fn {_n, idx}, {prev_window_sum, count} ->
  case Enum.slice(numbs, idx, 3) do
    [_, _, _] = window ->
      window_sum = Enum.sum(window)
      if window_sum > prev_window_sum, do: {window_sum, count + 1}, else: {window_sum, count}

    _ ->
      {prev_window_sum, count}
  end
end)
|> (fn {_, total} -> total end).()
|> IO.puts()

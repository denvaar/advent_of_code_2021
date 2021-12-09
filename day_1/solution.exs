"./input.txt"
|> File.read!()
|> String.split("\n")
|> Enum.reduce({-1, -1}, fn n, {prev, count} ->
  case Integer.parse(n) do
    :error ->
      {n, count}

    {current, ""} when current > prev ->
      {current, count + 1}

    {current, ""} ->
      {current, count}
  end
end)
|> (fn {"", total} -> total end).()
|> IO.puts()

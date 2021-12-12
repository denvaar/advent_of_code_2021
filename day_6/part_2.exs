run = fn
  0, _life, count, _run ->
    count

  n_days, 0, count, run ->
    run.(n_days - 1, 6, count + run.(n_days - 1, 8, 1, run), run)

  n_days, life, count, run ->
    run.(n_days - 1, life - 1, count, run)
end

# Go make dinner then come back to see the result 😂
n_days = 256

"./input.txt"
|> File.read!()
|> String.trim("\n")
|> String.split(",", trim: true)
|> Enum.frequencies()
|> Map.to_list()
|> Enum.map(fn {life, freq} ->
  Task.async(fn ->
    run.(n_days, String.to_integer(life), 1, run) * freq
  end)
end)
|> Task.await_many(:infinity)
|> Enum.sum()
|> IO.inspect(label: "Result")

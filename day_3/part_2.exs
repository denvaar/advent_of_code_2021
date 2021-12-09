determine_result = fn
  a, b, :oxygen ->
    if length(a) > length(b), do: a, else: b

  a, b, :co2 ->
    if length(a) <= length(b), do: a, else: b
end

iterate = fn numbers, col_idx, rating_type ->
  grouped =
    Enum.group_by(numbers, fn <<_::binary-size(col_idx), bit::binary-size(1), _rest::binary()>> ->
      bit
    end)

  %{"0" => zeros, "1" => ones} = grouped

  determine_result.(zeros, ones, rating_type)
end

rating_for = fn [sample | _hi_mom] = numbers, rating_type ->
  n_bits = String.length(sample)

  0..(n_bits - 1)
  |> Enum.reduce_while(numbers, fn col_idx, acc ->
    case iterate.(acc, col_idx, rating_type) do
      [result] -> {:halt, result}
      result -> {:cont, result}
    end
  end)
  |> :erlang.binary_to_integer(2)
end

# --- --- --- ---

initial_numbers =
  "./input.txt"
  |> File.read!()
  |> String.split("\n", trim: true)

life_support_rating =
  rating_for.(initial_numbers, :oxygen) *
    rating_for.(initial_numbers, :co2)

IO.puts(life_support_rating)

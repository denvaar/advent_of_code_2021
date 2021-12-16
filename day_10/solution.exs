operators = %{
  "[" => :push,
  "(" => :push,
  "{" => :push,
  "<" => :push,
  "]" => {:pop, "["},
  ")" => {:pop, "("},
  "}" => {:pop, "{"},
  ">" => {:pop, "<"}
}

points = %{
  ")" => 3,
  "]" => 57,
  "}" => 1197,
  ">" => 25137
}

parse_line = fn
  char, [last_push | tail] = stack ->
    case operators[char] do
      {:pop, expected} when expected == last_push ->
        {:cont, tail}

      {:pop, _expected} ->
        {:halt, {:error, char}}

      :push ->
        {:cont, [char | stack]}
    end

  char, [] ->
    case operators[char] do
      :push -> {:cont, [char]}
      _ -> {:halt, {:error, char}}
    end
end

sum_syntax_errors = fn
  {:error, invalid_char}, total -> total + points[invalid_char]
  _, total -> total
end

parse_input = fn line ->
  line
  |> String.split("", trim: true)
  |> Enum.reduce_while([], &parse_line.(&1, &2))
end

"input.txt"
|> File.read!()
|> String.split("\n", trim: true)
|> Enum.map(&parse_input.(&1))
|> Enum.reduce(0, &sum_syntax_errors.(&1, &2))
|> IO.inspect(label: "Result")

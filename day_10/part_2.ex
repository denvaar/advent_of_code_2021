defmodule NavSubsystem do
  defguard is_push(value) when value == "[" or value == "(" or value == "<" or value == "{"
  defguard is_pop(value) when value == "]" or value == ")" or value == ">" or value == "}"

  @matchers %{
    "{" => "}",
    "(" => ")",
    "<" => ">",
    "[" => "]"
  }

  @points %{
    ")" => 1,
    "]" => 2,
    "}" => 3,
    ">" => 4
  }

  def parse_chunks(data), do: parse(data, [])

  def autocomplete_score(stack), do: autocomplete_score(stack, 0)

  defp autocomplete_score([], score), do: score

  defp autocomplete_score([next | stack], score) do
    autocomplete_score(stack, 5 * score + @points[@matchers[next]])
  end

  defp parse([], []), do: {:ok, :valid_syntax, []}

  defp parse([], stack), do: {:error, :incomplete, stack}

  defp parse([char | data], stack) when is_push(char) do
    parse(data, [char | stack])
  end

  defp parse([char | data], [head | tail] = stack) when is_pop(char) do
    balanced? = @matchers[head] == char

    if balanced? do
      parse(data, tail)
    else
      {:error, :invalid_syntax, stack}
    end
  end

  defp parse(_data, stack), do: {:error, :invalid_syntax, stack}
end

"input.txt"
|> File.read!()
|> String.split("\n", trim: true)
|> Enum.reduce([], fn line, scores ->
  chunk_data = String.split(line, "", trim: true)

  case NavSubsystem.parse_chunks(chunk_data) do
    {:error, :incomplete, stack} ->
      [NavSubsystem.autocomplete_score(stack) | scores]

    _ ->
      scores
  end
end)
|> Enum.sort()
|> (fn x -> Enum.at(x, div(length(x), 2)) end).()
|> IO.inspect(label: "Result")

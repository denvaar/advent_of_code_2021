defmodule DumboLights do
  def count_flashes(_, 0, count), do: count

  def count_flashes(levels, iterations, count) do
    # each iteration in here is a "step".

    {n_flashes, levels, _} =
      Enum.reduce(
        0..(tuple_size(levels) - 1),
        {0, levels, %{}},
        fn idx, {count, levels, flashed_already} ->
          new_level =
            next_level(
              idx,
              elem(levels, idx),
              flashed_already
            )

          new_board = put_elem(levels, idx, new_level)
          flashed? = new_level == 0 && !flashed_already[idx]

          if flashed? do
            flashed_already = Map.put(flashed_already, idx, true)
            neighbors = DumboMap.neighbors(idx)

            {nb, flashed_already} = ripple(new_board, neighbors, flashed_already)

            {length(Map.keys(flashed_already)), nb, flashed_already}
          else
            {count, new_board, flashed_already}
          end
        end
      )

    count_flashes(levels, iterations - 1, count + n_flashes)
  end

  defp ripple(levels, [], flashed), do: {levels, flashed}

  defp ripple(levels, [idx | flasher_idxs], flashed) do
    new_level =
      next_level(
        idx,
        elem(levels, idx),
        flashed
      )

    new_board = put_elem(levels, idx, new_level)
    new_flash? = new_level == 0 and !flashed[idx]

    {neighbors, flashed} =
      if new_flash? do
        {flasher_idxs ++ DumboMap.neighbors(idx), Map.put(flashed, idx, true)}
      else
        {flasher_idxs, flashed}
      end

    ripple(new_board, neighbors, flashed)
  end

  defp next_level(current_idx, current_level, flashed_already) do
    if flashed_already[current_idx] do
      0
    else
      cycle(current_level)
    end
  end

  defp cycle(9), do: 0
  defp cycle(energy_level), do: energy_level + 1
end

defmodule DumboMap do
  @width 10
  @height 10

  @type direction ::
          :top
          | :top_left
          | :top_right
          | :left
          | :right
          | :bottom
          | :bottom_left
          | :bottom_right

  defguard is_left_edge(idx) when rem(idx, @width) == 0
  defguard is_right_edge(idx) when rem(idx + 1, @width) == 0
  defguard is_top_edge(idx) when idx < @width
  defguard is_bottom_edge(idx) when idx >= @width * @height - @width

  @spec neighbors(non_neg_integer()) :: list(non_neg_integer())
  @doc """
  Return all of the valid neighboring indices.
  """
  def neighbors(idx) do
    [:top_left, :top, :top_right, :left, :right, :bottom_left, :bottom, :bottom_right]
    |> Enum.map(&neighbor(&1, idx))
    |> Enum.filter(& &1)
  end

  @spec neighbor(direction(), non_neg_integer()) :: non_neg_integer() | nil
  defp neighbor(direction, idx)

  defp neighbor(:top_left, idx) when is_top_edge(idx) or is_left_edge(idx), do: nil
  defp neighbor(:top_left, idx), do: neighbor(:top, idx) - 1
  defp neighbor(:top, idx) when is_top_edge(idx), do: nil
  defp neighbor(:top, idx), do: idx - @width
  defp neighbor(:top_right, idx) when is_top_edge(idx) or is_right_edge(idx), do: nil
  defp neighbor(:top_right, idx), do: neighbor(:top, idx) + 1
  defp neighbor(:left, idx) when is_left_edge(idx), do: nil
  defp neighbor(:left, idx), do: idx - 1
  defp neighbor(:right, idx) when is_right_edge(idx), do: nil
  defp neighbor(:right, idx), do: idx + 1
  defp neighbor(:bottom_right, idx) when is_right_edge(idx) or is_bottom_edge(idx), do: nil
  defp neighbor(:bottom_right, idx), do: neighbor(:bottom, idx) + 1
  defp neighbor(:bottom, idx) when is_bottom_edge(idx), do: nil
  defp neighbor(:bottom, idx), do: idx + @width
  defp neighbor(:bottom_left, idx) when is_left_edge(idx) or is_bottom_edge(idx), do: nil
  defp neighbor(:bottom_left, idx), do: neighbor(:bottom, idx) - 1
end

levels =
  "input.txt"
  |> File.read!()
  |> String.split("", trim: true)
  |> Enum.reduce([], fn character, board ->
    case Integer.parse(character) do
      :error -> board
      {energy_level, ""} -> [energy_level | board]
    end
  end)
  |> Enum.reverse()
  |> List.to_tuple()

IO.inspect(
  DumboLights.count_flashes(levels, 100, 0),
  label: "Result"
)

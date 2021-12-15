read_input! = fn file ->
  [cols | _] =
    rows =
    file
    |> File.read!()
    |> String.split("\n", trim: true)

  heatmap =
    rows
    |> Enum.flat_map(fn row ->
      row
      |> String.split("", trim: true)
      |> Enum.map(&String.to_integer/1)
    end)
    |> List.to_tuple()

  %{
    heatmap: heatmap,
    row_width: String.length(cols),
    row_height: length(rows),
    last_idx: tuple_size(heatmap) - 1
  }
end

program = fn %{heatmap: heatmap, row_width: row_width, row_height: row_height, last_idx: last_idx} =
               _context ->
  top_neighbor = fn
    i when i <= row_width - 1 ->
      {nil, :infinity}

    i ->
      {i - row_width, elem(heatmap, i - row_width)}
  end

  bottom_neighbor = fn
    i when i >= row_width * row_height - row_width ->
      {nil, :infinity}

    i ->
      {i + row_width, elem(heatmap, i + row_width)}
  end

  left_neighbor = fn
    i when rem(i, row_width) == 0 ->
      {nil, :infinity}

    i ->
      {i - 1, elem(heatmap, i - 1)}
  end

  right_neighbor = fn
    i when rem(i + 1, row_width) == 0 ->
      {nil, :infinity}

    i ->
      {i + 1, elem(heatmap, i + 1)}
  end

  walk = fn
    [], _visited, count, _fn_binding ->
      count

    [idx | locations], visited, count, fn_binding ->
      neighbors =
        [
          left_neighbor.(idx),
          right_neighbor.(idx),
          top_neighbor.(idx),
          bottom_neighbor.(idx)
        ]
        |> Enum.filter(fn {n_idx, value} ->
          value < 9 && Map.get(visited, n_idx) == nil
        end)
        |> Enum.map(fn {n_idx, _value} -> n_idx end)

      visited =
        Enum.reduce(neighbors, visited, fn n_idx, acc ->
          Map.put(acc, n_idx, true)
        end)

      # yeah, I know ++ is "bad" -- who cares
      fn_binding.(locations ++ neighbors, visited, count + 1, fn_binding)
  end

  Enum.reduce(0..last_idx, [], fn idx, basins ->
    point = elem(heatmap, idx)

    [lowest_neighbor | _] =
      [
        left_neighbor.(idx),
        right_neighbor.(idx),
        top_neighbor.(idx),
        bottom_neighbor.(idx)
      ]
      |> Enum.map(fn {_idx, value} -> value end)
      |> Enum.sort()

    lowest? = lowest_neighbor > point

    if lowest? do
      basin_size = walk.([idx], %{idx => true}, 0, walk)
      [basin_size | basins]
    else
      basins
    end
  end)
  |> Enum.sort(:desc)
  |> (fn [first, second, third | _] -> first * second * third end).()
end

# -------------------------
# -------------------------
# -------------------------

"input.txt"
|> read_input!.()
|> program.()
|> IO.inspect(label: "Result")

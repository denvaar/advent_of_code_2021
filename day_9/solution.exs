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
      :infinity

    i ->
      elem(heatmap, i - row_width)
  end

  bottom_neighbor = fn
    i when i >= row_width * row_height - row_width ->
      :infinity

    i ->
      elem(heatmap, i + row_width)
  end

  left_neighbor = fn
    i when rem(i, row_width) == 0 ->
      :infinity

    i ->
      elem(heatmap, i - 1)
  end

  right_neighbor = fn
    i when rem(i + 1, row_width) == 0 ->
      :infinity

    i ->
      elem(heatmap, i + 1)
  end

  Enum.reduce(0..last_idx, 0, fn idx, sum ->
    point = elem(heatmap, idx)

    [lowest_neighbor | _] =
      Enum.sort([
        left_neighbor.(idx),
        right_neighbor.(idx),
        top_neighbor.(idx),
        bottom_neighbor.(idx)
      ])

    lowest? = lowest_neighbor > point

    if lowest?, do: sum + point + 1, else: sum
  end)
end

# -------------------------
# -------------------------
# -------------------------

"input.txt"
|> read_input!.()
|> program.()
|> IO.inspect(label: "Result")

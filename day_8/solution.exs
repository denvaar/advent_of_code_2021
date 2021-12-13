# number:   0 1 2 3 4 5 6 7 8 9
#           -------------------
# segments: 6 2 5 5 4 5 6 3 7 6
#           -------------------
# unique:     *     *     * *

unique_seg_counts = [2, 4, 3, 7]

get_input = fn file_name ->
  file_name
  |> File.read!()
  |> String.split("\n", trim: true)
  |> Enum.map(fn line ->
    [_, digit_output] =
      String.split(
        line,
        " | ",
        trim: true
      )

    digit_output
  end)
end

get_input.("./input.txt")
|> Enum.flat_map(&String.split(&1, " ", trim: true))
|> Enum.group_by(&String.length/1)
|> Map.to_list()
|> Enum.reduce(0, fn {n_segments, segs}, acc ->
  if n_segments in unique_seg_counts do
    acc + length(segs)
  else
    acc
  end
end)
|> IO.inspect(label: "Result")

sort = fn pattern ->
  pattern
  |> String.split("", trim: true)
  |> Enum.sort()
  |> Enum.join("")
end

find_by_length = fn patterns, len ->
  Enum.find(
    patterns,
    &(String.length(&1) == len)
  )
end

filter_by_length = fn patterns, len ->
  Enum.filter(
    patterns,
    &(String.length(&1) == len)
  )
end

add_easy_ones = fn codes, patterns ->
  # easy ones are 1, 4, 7, 8
  # because they each have a
  # unique number of segments.
  codes
  |> put_elem(1, find_by_length.(patterns, 2))
  |> put_elem(4, find_by_length.(patterns, 4))
  |> put_elem(7, find_by_length.(patterns, 3))
  |> put_elem(8, find_by_length.(patterns, 7))
end

deduce_digit_3 = fn codes, patterns ->
  # 3 should be the only pattern of
  # length 5 that has all values of
  # 7's pattern.
  possible_3s = filter_by_length.(patterns, 5)

  values_from_7 =
    codes
    |> elem(7)
    |> String.split("", trim: true)

  deduced_3 =
    Enum.find(possible_3s, fn pattern ->
      pattern = String.split(pattern, "", trim: true)

      length(Enum.filter(pattern, fn p -> p in values_from_7 end)) == length(values_from_7)
    end)

  put_elem(codes, 3, deduced_3)
end

deduce_digit_9 = fn codes, patterns ->
  # 9 should be the only pattern of
  # length 6 that includes all values
  # from 4's pattern.
  possible_9s = filter_by_length.(patterns, 6)

  values_from_4 =
    codes
    |> elem(4)
    |> String.split("", trim: true)

  deduced_9 =
    Enum.find(possible_9s, fn pattern ->
      pattern = String.split(pattern, "", trim: true)

      length(Enum.filter(pattern, fn p -> p in values_from_4 end)) == length(values_from_4)
    end)

  put_elem(codes, 9, deduced_9)
end

deduce_digit_0 = fn codes, patterns ->
  # 0 should be the only pattern
  # of length 6 (after deducing
  # digit 9) to include all values
  # from 7's pattern.
  possible_0s =
    patterns
    |> filter_by_length.(6)
    |> Enum.reject(fn pattern ->
      pattern == elem(codes, 9)
    end)

  values_from_7 =
    codes
    |> elem(7)
    |> String.split("", trim: true)

  deduced_0 =
    Enum.find(possible_0s, fn pattern ->
      pattern = String.split(pattern, "", trim: true)

      length(Enum.filter(pattern, fn p -> p in values_from_7 end)) == length(values_from_7)
    end)

  put_elem(codes, 0, deduced_0)
end

deduce_digit_6 = fn codes, patterns ->
  # 6 is the last remaining pattern
  # having length of 6 after 9 and 0
  # have been deduced.
  [deduced_6] =
    patterns
    |> filter_by_length.(6)
    |> Enum.reject(fn pattern ->
      pattern == elem(codes, 9) or
        pattern == elem(codes, 0)
    end)

  put_elem(codes, 6, deduced_6)
end

deduce_digit_5 = fn codes, patterns ->
  # 5 is the only pattern of length
  # 5 where all values are also in
  # 6's pattern.
  possible_5s =
    patterns
    |> filter_by_length.(5)
    |> Enum.reject(fn pattern ->
      pattern == elem(codes, 3)
    end)

  values_from_6 =
    codes
    |> elem(6)
    |> String.split("", trim: true)
    |> MapSet.new()

  deduced_5 =
    Enum.find(possible_5s, fn pattern ->
      pattern = String.split(pattern, "", trim: true)

      values_from_6
      |> MapSet.difference(MapSet.new(pattern))
      |> MapSet.to_list()
      |> length()
      |> Kernel.==(1)
    end)

  put_elem(codes, 5, deduced_5)
end

deduce_digit_2 = fn codes, patterns ->
  [deduced_2] =
    patterns
    |> filter_by_length.(5)
    |> Enum.reject(fn pattern ->
      pattern == elem(codes, 3) or
        pattern == elem(codes, 5)
    end)

  put_elem(codes, 2, deduced_2)
end

decode = fn patterns ->
  # order matters
  {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil}
  |> add_easy_ones.(patterns)
  |> deduce_digit_3.(patterns)
  |> deduce_digit_9.(patterns)
  |> deduce_digit_0.(patterns)
  |> deduce_digit_6.(patterns)
  |> deduce_digit_5.(patterns)
  |> deduce_digit_2.(patterns)
  |> Tuple.to_list()
  |> Enum.map(&sort.(&1))
  |> Enum.with_index()
  |> Map.new()
end

sum_outputs = fn outputs, mapping ->
  reading =
    Enum.reduce(outputs, "", fn output, sum ->
      "#{sum}#{mapping[output]}"
    end)

  String.to_integer(reading)
end

get_input = fn file_name ->
  file_name
  |> File.read!()
  |> String.split("\n", trim: true)
  |> Enum.map(fn line ->
    [patterns, outputs] =
      String.split(
        line,
        " | ",
        trim: true
      )

    to_list = fn str ->
      str
      |> String.split(" ", trim: true)
      |> Enum.map(&sort.(&1))
    end

    [to_list.(patterns), to_list.(outputs)]
  end)
end

get_input.("./input.txt")
|> Enum.reduce(0, fn [patterns, outputs], total ->
  mapping = decode.(patterns)
  total + sum_outputs.(outputs, mapping)
end)
|> IO.inspect(label: "Result")

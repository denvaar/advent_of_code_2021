n_bits_per_row = 12
# wc -l input.txt
encoding_length = 1_000

bits =
  "./input.txt"
  |> File.read!()
  |> String.replace("\n", "")
  |> String.split("", trim: true)

popcount = fn
  "", _func -> 0
  <<"1", rest::bitstring>>, func -> 1 + func.(rest, func)
  <<"0", rest::bitstring>>, func -> func.(rest, func)
end

gamma =
  0..(n_bits_per_row - 1)
  |> Enum.map(fn idx ->
    bits
    |> Enum.slice(idx, 99_000_000)
    |> Enum.take_every(n_bits_per_row)
    |> Enum.join("")
  end)
  |> Enum.reduce("", fn encoding, value ->
    if popcount.(encoding, popcount) >= encoding_length / 2 do
      value <> "1"
    else
      value <> "0"
    end
  end)
  |> :erlang.binary_to_integer(2)

epsilon =
  for <<bit <- :erlang.integer_to_binary(gamma, 2)>>, into: "" do
    # flip bits
    case bit do
      48 -> "1"
      49 -> "0"
    end
  end
  |> :erlang.binary_to_integer(2)

IO.puts(gamma * epsilon)

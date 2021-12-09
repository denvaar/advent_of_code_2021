bingo? = fn bingos, board_numbers ->
  Enum.all?(board_numbers, fn n ->
    Enum.member?(bingos, n)
  end)
end

check_board_rows = fn bingos, board ->
  bingos? =
    board
    |> Enum.chunk_every(5)
    |> Enum.map(fn row ->
      Task.async(fn ->
        bingo?.(bingos, row)
      end)
    end)
    |> Task.await_many()
    |> Enum.any?()

  if bingos?, do: board, else: []
end

rotate = fn board ->
  rotate = fn
    _board, rotated_board, _this_func when length(rotated_board) == 5 ->
      List.flatten(rotated_board)

    [_ | next_board] = board, rotated_board, this_func ->
      column = Enum.take_every(board, 5)

      this_func.(next_board, [column | rotated_board], this_func)
  end

  rotate.(board, [], rotate)
end

calculate_answer = fn board, [last_called | _] = numbers ->
  numbers = Enum.map(numbers, &String.to_integer/1)
  last_called = String.to_integer(last_called)

  board
  |> Enum.map(&String.to_integer/1)
  |> Enum.reject(fn board_number ->
    Enum.member?(numbers, board_number)
  end)
  |> Enum.sum()
  |> Kernel.*(last_called)
end

[raw_bingo_numbers | raw_boards] =
  "./input.txt"
  |> File.stream!()
  |> Enum.map(fn row -> row end)

bingo_numbers =
  raw_bingo_numbers
  |> String.trim()
  |> String.split(",")

boards =
  raw_boards
  |> Enum.map(fn x ->
    x
    |> String.trim()
    |> String.split(" ", trim: true)
  end)
  |> Enum.chunk_by(fn line ->
    line == []
  end)
  |> Enum.reject(fn row -> row == [[]] end)
  |> Enum.map(fn board -> List.flatten(board) end)

# accumulator:   { [] , { [],       [] } }
#                 /      /         /
#       called numbers  loosers   winners
{_, {_, winners}} =
  Enum.reduce(bingo_numbers, {[], {boards, []}}, fn n, {called, {loosers, winners}} ->
    called = [n | called]

    boards =
      Enum.reduce(loosers, {[], winners}, fn board, {l, w} ->
        winner_by_row = check_board_rows.(called, board)
        winner_by_col = check_board_rows.(called, rotate.(board))

        cond do
          winner_by_row != [] ->
            answer = calculate_answer.(winner_by_row, called)
            {l, [answer | w]}

          winner_by_col != [] ->
            answer = calculate_answer.(winner_by_col, called)
            {l, [answer | w]}

          true ->
            {[board | l], w}
        end
      end)

    {called, boards}
  end)

winners
|> Enum.reverse()
|> List.first()
|> IO.puts()

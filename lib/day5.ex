defmodule AdventOfCode.Day5 do
  @encoding_regex ~r/^([FB]{7})([LR]{3})$/
  @ranges %{
    :rows => %{
      "F" => :lower,
      "B" => :upper
    },
    :columns => %{
      "L" => :lower,
      "R" => :upper
    }
  }

  @spec compute_range([binary], :columns | :rows) :: integer
  def compute_range(input, :rows) do
    %{:rows => encodings} = @ranges
    compute_range(input, {0, 127}, encodings)
  end

  def compute_range(input, :columns) do
    %{:columns => encodings} = @ranges
    compute_range(input, {0, 7}, encodings)
  end

  defp compute_range([], {_, pos}, _) do
    pos
  end

  defp compute_range([encoded_pos | rest], {min, max}, encodings) do
    %{^encoded_pos => movement} = encodings

    new_pos =
      case movement do
        :upper -> {Integer.floor_div(min + max, 2), max}
        :lower -> {min, Integer.floor_div(min + max, 2)}
      end

    compute_range(rest, new_pos, encodings)
  end

  @spec find_missing_seat([{integer, integer, integer}], [{integer, integer, integer}]) :: [
          {integer, integer, integer}
        ]
  def find_missing_seat([], acc) do
    acc
  end

  def find_missing_seat([{_, _, _}], acc) do
    acc
  end

  def find_missing_seat([{row, prev_col, _} | [{row, next_col, _} | _] = cont], acc) do
    empty_col = prev_col + 1

    case empty_col == next_col do
      true ->
        find_missing_seat(cont, acc)

      false ->
        find_missing_seat(cont, [{row, empty_col, row * 8 + empty_col} | acc])
    end
  end

  def find_missing_seat([{_, _, _} | [{_, _, _} | _] = cont], acc) do
    find_missing_seat(cont, acc)
  end

  def day5() do
    rows_columns_ids =
      "day5_input"
      |> AdventOfCode.read_file()
      |> Enum.map(fn encoding ->
        case Regex.run(@encoding_regex, encoding) do
          nil ->
            :invalid

          [_, row_encoding, column_encoding] ->
            column =
              column_encoding
              |> String.graphemes()
              |> compute_range(:columns)

            row =
              row_encoding
              |> String.graphemes()
              |> compute_range(:rows)

            {row, column, row * 8 + column}
        end
      end)

    max_id =
      Enum.reduce(rows_columns_ids, 0, fn {_, _, act_id}, max_id ->
        max(max_id, act_id)
      end)

    missing_seat =
      rows_columns_ids
      |> Enum.sort()
      |> find_missing_seat([])

    {rows_columns_ids, max_id, missing_seat}
  end
end

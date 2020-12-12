defmodule AdventOfCode.Day11 do
  def get_value(input, row, col) do
    case (x = Matrex.at(input, row, col)) < 0 do
      true -> 0
      false -> floor(x)
    end
  end

  def neighborhood_value(input, row, col) do
    center_value = get_value(input, row, col)

    value =
      Enum.reduce([-1, 0, 1], 0, fn row_off, count ->
        Enum.reduce([-1, 0, 1], count, fn col_off, count ->
          count + get_value(input, row + row_off, col + col_off)
        end)
      end)

    value - center_value
  end

  def explore_direction(_input, {_row, _col}, 0, 0) do
    0
  end

  def explore_direction(_input, {row, col}, _off_row, _off_col) when row <= 0 or col <= 0 do
    0
  end

  def explore_direction(input, {row, col}, off_row, off_col) do
    {num_rows, num_cols} = input[:size]

    case row > num_rows or col > num_cols do
      true ->
        0

      false ->
        value =
          input
          |> Matrex.at(row, col)
          |> floor()

        case value do
          1 -> 1
          0 -> 0
          _ -> explore_direction(input, {row + off_row, col + off_col}, off_row, off_col)
        end
    end
  end

  def single_seat_neighborhood_value(input, row, col) do
    Enum.reduce([-1, 0, 1], 0, fn row_off, count ->
      Enum.reduce([-1, 0, 1], count, fn col_off, count ->
        count + explore_direction(input, {row + row_off, col + col_off}, row_off, col_off)
      end)
    end)
  end

  @spec evaluate_rule(integer, 0 | 1, :relaxed | :original) :: 0 | 1
  def evaluate_rule(0, _, _), do: 1

  def evaluate_rule(value, _, :relaxed) when value >= 5 do
    0
  end

  def evaluate_rule(value, _, :original) when value >= 4 do
    0
  end

  def evaluate_rule(_, current_value, _) do
    current_value
  end

  def step(_input, _agg, start_pos, end_pos, acc) when start_pos > end_pos do
    acc
  end

  def step(input, agg, {row, col}, {_end_row, end_col} = end_pos, acc) when col > end_col do
    step(input, agg, {row + 1, 2}, end_pos, acc)
  end

  def step(input, {agg_value, agg_rule} = agg, {row, col}, end_pos, {acc, count_ones}) do
    case Matrex.at(input, row, col) < 0 do
      true ->
        step(input, agg, {row, col + 1}, end_pos, {acc, count_ones})

      false ->
        current_value = get_value(input, row, col)
        neigh_value = agg_value.(input, row, col)
        new_value = agg_rule.(neigh_value, current_value)
        acc = Matrex.set(acc, row, col, new_value)
        count_ones = count_ones + new_value
        step(input, agg, {row, col + 1}, end_pos, {acc, count_ones})
    end
  end

  def life(
        input,
        agg_value \\ &neighborhood_value/3,
        agg_rule \\ fn x, y -> evaluate_rule(x, y, :original) end
      ) do
    {total_rows, total_cols} = input[:size]

    {next_input, ones} =
      step(input, {agg_value, agg_rule}, {2, 2}, {total_rows - 1, total_cols - 1}, {input, 0})

    diff =
      input
      |> Matrex.add(next_input, 1.0, -1.0)
      |> Matrex.sum()
      |> floor()

    case diff do
      0 -> {input, ones}
      _ -> life(next_input, agg_value, agg_rule)
    end
  end

  def print_board(mat) do
    {rows, cols} = mat[:size]

    mat
    |> Matrex.to_list_of_lists()
    |> Enum.slice(1..(rows - 2))
    |> Enum.reduce("", fn row, acc ->
      row = Enum.slice(row, 1..(cols - 2))

      row_repr =
        Enum.reduce(row, "", fn value, acc ->
          value = floor(value)

          str_value =
            case value do
              -1 -> "."
              0 -> "L"
              1 -> "#"
            end

          "#{acc}#{str_value}"
        end)

      "#{acc}\n#{row_repr}"
    end)
  end

  def day11() do
    input =
      "day11_input"
      |> AdventOfCode.read_file()
      |> Enum.map(fn row ->
        parsed_row =
          row
          |> String.graphemes()
          |> Enum.map(fn entry ->
            case entry do
              "." -> -1
              "L" -> 0
              "#" -> 1
            end
          end)

        [-1 | parsed_row] ++ [-1]
      end)

    [first_row | _] = input
    empty_row = for _ <- first_row, do: -1
    input = [empty_row | input] ++ [empty_row]
    mat = Matrex.new(input)
    {_result, part1} = life(mat)

    {_, part2} =
      life(mat, &single_seat_neighborhood_value/3, fn x, y -> evaluate_rule(x, y, :relaxed) end)

    {mat, part1, part2}
  end
end

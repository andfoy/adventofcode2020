defmodule AdventOfCode.Day1 do
  def multiply_year(list, value) do
    values =
      Enum.reduce(list, [], fn x, acc ->
        Enum.reduce(list, acc, fn y, acc2 ->
          case x + y do
            ^value -> {x, y}
            _ -> acc2
          end
        end)
      end)

    case values do
      {x, y} -> x * y
      _ -> nil
    end
  end

  def multiply_year_3(list, value) do
    values =
      Enum.reduce(list, [], fn x, acc ->
        Enum.reduce(list, acc, fn y, acc2 ->
          Enum.reduce(list, acc2, fn z, acc3 ->
            case x + y + z do
              ^value -> {x, y, z}
              _ -> acc3
            end
          end)
        end)
      end)

      case values do
        {x, y, z} -> x * y * z
        _ -> nil
      end
  end

  def day1() do
    # Part 1
    input =
      :advent_of_code
      |> :code.priv_dir()
      |> Path.join("day1_input")
      |> File.read!()
      |> String.split()
      |> Enum.map(fn x ->
         {val, _} = Integer.parse(x)
         val
      end)

    part_1_ans = multiply_year(input, 2020)
    # {:ok, file} = File.open!(file_in)
    :logger.debug("Part 1: #{inspect part_1_ans}")

    part_2_ans = multiply_year_3(input, 2020)
    :logger.debug("Part 2: #{inspect part_2_ans}")
  end
end

defmodule AdventOfCode.Day3 do
  @spec count_trees([binary], integer, integer | nil) :: {integer, integer, boolean}
  def count_trees(map_lines, slope \\ 3, starting_pos \\ nil) do
    [first_line | _] = map_lines
    num_cols = String.length(first_line)

    starting_pos =
      case starting_pos do
        nil -> slope
        _ -> starting_pos
      end

    map_lines
    |> Enum.reduce({0, starting_pos, true}, fn line, {count, pos, first} ->
      case first do
        true ->
          {count, pos, false}

        false ->
          new_count =
            case String.at(line, pos) do
              "#" ->
                count + 1

              _ ->
                count
            end

          {new_count, rem(pos + slope, num_cols), first}
      end
    end)
  end

  @spec day3 :: {number, number}
  def day3() do
    map_lines =
      "day3_input"
      |> AdventOfCode.read_file()

    {part1, _, _} = count_trees(map_lines)
    # :logger.debug("Part 1: #{inspect(part1)}")

    {slope1, _, _} = count_trees(map_lines, 1, 2)
    {slope5, _, _} = count_trees(map_lines, 5)
    {slope7, _, _} = count_trees(map_lines, 7)

    {slope2, _, _} =
      map_lines
      |> Enum.take_every(2)
      |> count_trees(1)

    # :logger.debug("#{part1} * #{slope1} * #{slope2} * #{slope5} * #{slope7}")
    part2 = part1 * slope1 * slope2 * slope5 * slope7
    # :logger.debug("Part 2: #{inspect(part2)}")
    {part1, part2}
  end
end

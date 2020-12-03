defmodule AdventOfCode.Day3 do
  def count_trees(map_lines, slope \\ 3) do
    [first_line | _] = map_lines
    num_cols = String.length(first_line)

    map_lines
    |> Enum.chunk_every(Integer.floor_div(num_cols + 1, slope))
    |> Enum.reduce({0, 0, true}, fn line_group, {count, off, first} ->
      # :logger.debug("Starting offset: #{inspect off}")
      {count, prev_pos, first} =
        Enum.reduce(line_group, {count, slope - off, first}, fn cur_line,
                                                                {count, position, first} ->
          case first do
            true ->
              {count, position, false}

            false ->
              # :logger.debug("#{inspect cur_line} #{position}")
              # :logger.debug("#{inspect String.at(cur_line, position)}")
              new_count =
                case String.at(cur_line, position) do
                  "#" ->
                    count + 1

                  _ ->
                    count
                end

              {new_count, position + slope, first}
          end
        end)

      # :logger.debug("Group end pos #{inspect prev_pos - slope + 1} / #{inspect num_cols}")
      new_off = rem(num_cols - prev_pos + slope, num_cols)
      # :logger.debug("Leftover offset #{inspect new_off}")
      {count, new_off, first}
    end)
  end

  def day3() do
    map_lines =
      "day3_input"
      |> AdventOfCode.read_file()

    {part1, _, _} = count_trees(map_lines)
    :logger.debug("Part1: #{inspect(part1)}")

    {slope1, _, _} = count_trees(map_lines, 1)
    {slope5, _, _} = count_trees(map_lines, 5)
    {slope7, _, _} = count_trees(map_lines, 7)

    {slope2, _, _} =
      map_lines
      |> Enum.take_every(2)
      |> count_trees(1)

    part2 = part1 * slope1 * slope2 * slope5 * slope7
  end
end

defmodule AdventOfCode.Day6 do
  @spec day6 :: {[{MapSet.t(), MapSet.t()}], {integer, integer}}
  def day6() do
    "day6_input"
    |> AdventOfCode.read_file()
    |> Enum.chunk_while([], &AdventOfCode.chunk_by_empty/2, &AdventOfCode.chunk_after/1)
    |> Enum.map_reduce({0, 0}, fn group, {num_union, num_intersection} ->
      {group_union, group_intersection, _} =
        Enum.reduce(group, {MapSet.new(), MapSet.new(), true}, fn person_ans,
                                                                  {union, intersection, first} ->
          person_set =
            person_ans
            |> String.graphemes()
            |> MapSet.new()

          union = MapSet.union(person_set, union)

          intersection =
            case first do
              true -> person_set
              false -> MapSet.intersection(person_set, intersection)
            end

          {union, intersection, false}
        end)

      total_union = MapSet.size(group_union) + num_union
      total_intersection = MapSet.size(group_intersection) + num_intersection
      {{group_union, group_intersection}, {total_union, total_intersection}}
    end)
  end
end

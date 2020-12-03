defmodule AdventOfCodeDay3Test do
  use ExUnit.Case
  doctest AdventOfCode.Day3

  test "benchmark speed" do
    {part1, part2} = AdventOfCode.Day3.day3()
    assert part1 == 242 and part2 == 2016891888

    Benchee.run(%{
      "day3" => &AdventOfCode.Day3.day3/0
    })

    assert true
  end
end

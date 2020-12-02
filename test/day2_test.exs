defmodule AdventOfCodeDay2Test do
  use ExUnit.Case
  doctest AdventOfCode.Day2

  test "benchmark speed" do
    {part1, part2} = AdventOfCode.Day2.day2()
    assert part1 == 383 and part2 == 272

    Benchee.run(%{
      "day2" => &AdventOfCode.Day2.day2/0
    })

    assert true
  end
end

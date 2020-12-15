defmodule AdventOfCode.Day15 do

  def update_last_appearance(value, step, seen) do
    case Map.get(seen, value) do
      nil -> Map.put(seen, value, {nil, step})
      {_, prev} -> Map.put(seen, value, {prev, step})
    end
  end

  def play_game(current, steps, steps, _) do
    current
  end

  def play_game(current, current_step, steps, seen) do
    # :logger.debug("Turn #{inspect current_step} - last spoken: #{inspect current}")
    case Map.get(seen, current) do
      {nil, _} ->
        seen = update_last_appearance(0, current_step, seen)
        play_game(0, current_step + 1, steps, seen)

      {second_to_last, last} ->
        next_value = last - second_to_last
        seen = update_last_appearance(next_value, current_step, seen)
        play_game(next_value, current_step + 1, steps, seen)
    end
  end

  def game(starting, steps) do
    # {first_seen, [current|_]} = Enum.split(starting, length(starting) - 1)
    {step, seen, current} = Enum.reduce(starting, {1, %{}, -1}, fn num, {pos, seen, _} ->
      seen = Map.put(seen, num, {nil, pos})
      {pos + 1, seen, num}
    end)
    play_game(current, step, steps, seen)
  end

  def day15() do
    numbers =
      "day15_input"
      |> AdventOfCode.read_file()
      |> Enum.at(0)
      |> String.split(",")
      |> Enum.map(fn x ->
        {value, _} = Integer.parse(x)
        value
      end)

    # game_queue = :queue.from_list(numbers)
    part1 = game(numbers, 2021)
    part2 = game(numbers, 30_000_001)
    {part1, part2}
  end
end

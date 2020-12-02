defmodule AdventOfCode.Day2 do
  @spec check_password_count([{integer, integer, binary, binary}], integer) :: integer
  def check_password_count([], result) do
    result
  end


  def check_password_count([{min, max, letter, password} | rest], result) do
    char_count =
      password
      |> String.to_charlist()
      |> Enum.reduce(%{}, fn c, acc ->
        count = Map.get(acc, c, 0)
        Map.put(acc, c, count + 1)
      end)

    [letter] = String.to_charlist(letter)
    letter_ocurrences = Map.get(char_count, letter, 0)
    complies = letter_ocurrences >= min and letter_ocurrences <= max
    check_password_count(rest, AdventOfCode.boolean_to_integer(complies) + result)
  end

  @spec check_password_position([{integer, integer, binary, binary}], integer) :: integer
  def check_password_position([], result) do
    result
  end

  def check_password_position([{pos1, pos2, letter, password} | rest], result) do
    password = String.graphemes(password)

    pos1_valid =
      AdventOfCode.boolean_to_integer(match?({^letter, _}, List.pop_at(password, pos1 - 1)))

    pos2_valid =
      AdventOfCode.boolean_to_integer(match?({^letter, _}, List.pop_at(password, pos2 - 1)))

    valid = Bitwise.bxor(pos1_valid, pos2_valid)
    check_password_position(rest, result + valid)
  end

  @spec day2 :: {integer, integer}
  def day2() do
    lines =
      "day2_input"
      |> AdventOfCode.read_file()
      |> Enum.map(fn x ->
        [min, max, letter, "", password] = String.split(x, ["-", " ", ":"])
        {min, _} = Integer.parse(min)
        {max, _} = Integer.parse(max)
        {min, max, letter, password}
      end)

    part1 = check_password_count(lines, 0)
    part2 = check_password_position(lines, 0)

    {part1, part2}
  end
end

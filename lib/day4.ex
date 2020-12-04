defmodule AdventOfCode.Day4 do
  alias AdventOfCode.Day4, as: Day4

  @required_keys [:byr, :iyr, :eyr, :hgt, :hcl, :ecl, :pid]
  # @optional_keys [:cid]

  def parsers() do
    %{
      :byr => fn x -> Day4.parse_integer(x, fn v -> v >= 1920 and v <= 2002 end) end,
      :iyr => fn x -> Day4.parse_integer(x, fn v -> v >= 2010 and v <= 2020 end) end,
      :eyr => fn x -> Day4.parse_integer(x, fn v -> v >= 2020 and v <= 2030 end) end,
      :hgt => &Day4.parse_height/1,
      :hcl => &Day4.parse_hair/1,
      :ecl => &Day4.parse_eye/1,
      :pid => &Day4.parse_passport_id/1
    }
  end

  @spec parse_integer(binary, (binary -> boolean)) :: boolean
  def parse_integer(int, limit_fn) do
    case Integer.parse(int) do
      {value, _} ->
        limit_fn.(value)
      :error -> false
    end
  end

  @spec parse_height(binary) :: boolean
  def parse_height(height) do
    height_regex = ~r/^(\d+)(cm|in)$/
    case Regex.run(height_regex, height) do
      nil -> false
      [_, number, units] ->
        {number, _} = Integer.parse(number)
        case units do
          "cm" -> number >= 150 and number <= 193
          "in" -> number >= 59 and number <= 76
        end
    end
  end

  @spec parse_hair(binary) :: boolean
  def parse_hair(hair) do
    hair_regex = ~r/^#[0-9a-f]{6}$/
    String.match?(hair, hair_regex)
  end

  @spec parse_eye(binary) :: boolean
  def parse_eye(eye) do
    eye_regex = ~r/^(amb|blu|brn|gry|grn|hzl|oth)$/
    String.match?(eye, eye_regex)
  end

  @spec parse_passport_id(binary) :: boolean
  def parse_passport_id(pass_id) do
    pass_id_regex = ~r/^\d{9}$/
    # id_length_valid = String.length(pass_id) == 9
    # id_is_number = parse_integer(pass_id)
    # id_length_valid and id_is_number
    String.match?(pass_id, pass_id_regex)
  end

  def validate_key(passport, key) do
    validator = Map.get(parsers(), key)

    passport
    |> Map.get(key)
    |> validator.()
  end

  def chunk_by_empty(element, acc) do
    if element == "" do
      {:cont, Enum.reverse(acc), []}
    else
      {:cont, [element | acc]}
    end
  end

  def chunk_after(acc) do
    case acc do
      [] -> {:cont, []}
      acc -> {:cont, Enum.reverse(acc), []}
    end
  end

  def parse_passport(passport) do
    passport
    |> String.split()
    |> Enum.reduce(%{}, fn part, acc ->
      [key, value] = String.split(part, ":")
      key = String.to_atom(key)
      Map.put(acc, key, value)
    end)
  end

  def count_valid([], acc, _) do
    acc
  end

  def count_valid([passport | rest], acc, validate) do
    complies_required =
      Enum.all?(@required_keys, fn k ->
        key_present = Map.has_key?(passport, k)

        case validate do
          false -> key_present
          true -> key_present and validate_key(passport, k)
        end
      end)

    count_valid(rest, AdventOfCode.boolean_to_integer(complies_required) + acc, validate)
  end

  def day4() do
    passports =
      "day4_input"
      |> AdventOfCode.read_file()
      |> Enum.chunk_while([], &chunk_by_empty/2, &chunk_after/1)
      |> Enum.map(fn pass ->
        pass
        |> Enum.join(" ")
        |> parse_passport()
      end)

    valid = count_valid(passports, 0, false)
    present_and_valid = count_valid(passports, 0, true)
    {valid, present_and_valid}
  end
end

defmodule AdventOfCode.Day14 do
  @mask_regex ~r/^mask = ([01X]{36})$/
  @mem_assignment ~r/^mem\[(\d+)\] = (\d+)$/

  def convert_to_binary(num) do
    default_binary = (for x <- 0..35, do: {x, 0}) |> Enum.into(%{})
    {_, bin} =
      num
      |> :erlang.integer_to_list(2)
      |> Enum.reverse()
      |> Enum.reduce({0, default_binary}, fn bin, {pos, acc} ->
        bin = bin - 48
        acc = Map.put(acc, pos, bin)
        {pos + 1, acc}
      end)
    bin
  end

  def binary_to_int(bin) do
    bin
    |> Map.to_list()
    |> Enum.sort(:desc)
    |> Enum.map(fn {_, v} -> v + 48 end)
    |> :erlang.list_to_integer(2)
  end

  def parse_mask(mask) do
    mask
    |> Enum.reverse()
    |> Enum.reduce({0, %{}}, fn x, {pos, acc} ->
      case x do
        "X" -> {pos + 1, acc}
        "0" -> {pos + 1, Map.put(acc, pos, 0)}
        "1" -> {pos + 1, Map.put(acc, pos, 1)}
      end
    end)
  end

  def parse_mask(mask, :v2) do
    mask
    |> Enum.reverse()
    |> Enum.reduce({0, %{}}, fn x, {pos, acc} ->
      case x do
        "X" -> {pos + 1, Map.put(acc, pos, :X)}
        "0" -> {pos + 1, Map.put(acc, pos, 0)}
        "1" -> {pos + 1, Map.put(acc, pos, 1)}
      end
    end)
  end

  def compute_addresses(bin_pos, _, 36) do
    [binary_to_int(bin_pos)]
  end

  def compute_addresses(bin_pos, mask, pos) do
    %{^pos => value} = mask
    case value do
      0 -> compute_addresses(bin_pos, mask, pos + 1)
      1 ->
        new_bin_pos = Map.put(bin_pos, pos, 1)
        compute_addresses(new_bin_pos, mask, pos + 1)
      :X ->
        one_bin_pos = Map.put(bin_pos, pos, 1)
        zero_bin_pos = Map.put(bin_pos, pos, 0)
        left_results = compute_addresses(one_bin_pos, mask, pos + 1)
        right_results = compute_addresses(zero_bin_pos, mask, pos + 1)
        left_results ++ right_results
      end
  end

  def day14() do
    input =
      "day14_input"
      |> AdventOfCode.read_file()

    {memory, _mask} =
      Enum.reduce(input, {%{}, %{}}, fn line, {mem, mask} ->
        case Regex.run(@mask_regex, line) do
          :nil ->
            [_, pos, value] = Regex.run(@mem_assignment, line)
            {pos, _} = Integer.parse(pos)
            {value, _} = Integer.parse(value)
            bin_value = convert_to_binary(value)
            bin_value = Map.merge(bin_value, mask)
            new_value = binary_to_int(bin_value)
            mem = Map.put(mem, pos, new_value)
            {mem, mask}
          [_, value] ->
            {_, mask} =
              value
              |> String.graphemes()
              |> parse_mask()
            {mem, mask}
        end
      end)

      part1 = Enum.reduce(memory, 0, fn {_k, v}, acc -> v + acc end)

    {memory, _} =
      Enum.reduce(input, {%{}, %{}}, fn line, {mem, mask} ->
        case Regex.run(@mask_regex, line) do
          :nil ->
            [_, pos, value] = Regex.run(@mem_assignment, line)
            {pos, _} = Integer.parse(pos)
            {value, _} = Integer.parse(value)
            bin_pos = convert_to_binary(pos)
            all_positions = compute_addresses(bin_pos, mask, 0)
            mem = Enum.reduce(all_positions, mem, fn pos, mem ->
              Map.put(mem, pos, value)
            end)
            # bin_value = convert_to_binary(value)
            # bin_value = Map.merge(bin_value, mask)
            # new_value = binary_to_int(bin_value)
            # mem = Map.put(mem, pos, new_value)
            {mem, mask}
          [_, value] ->
            {_, mask} =
              value
              |> String.graphemes()
              |> parse_mask(:v2)
            {mem, mask}
        end
      end)

    part2 = Enum.reduce(memory, 0, fn {_k, v}, acc -> v + acc end)
    {part1, part2}
  end
end

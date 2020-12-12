defmodule AdventOfCode.Day10 do

  def test_adapters(adapters, current_joltage) do
    test_adapters(adapters, current_joltage, 0, 0)
  end

  def test_adapters([], _, num_ones, num_threes) do
    {num_ones, num_threes}
  end

  def test_adapters([adapter|adapters], current_joltage, num_ones, num_threes) do
    {num_ones, num_threes} =
       case adapter - current_joltage do
        1 -> {num_ones + 1, num_threes}
        3 -> {num_ones, num_threes + 1}
      end
    test_adapters(adapters, adapter, num_ones, num_threes)
  end

  @spec fill_row(integer, [integer], integer, integer, Matrex.t()) :: Matrex.t()
  def fill_row(_, [], _row, _col, mat) do
    mat
  end

  def fill_row(adapter, [other_adapter | rest], row, col, mat) do
    diff = abs(adapter - other_adapter)
    value = AdventOfCode.boolean_to_integer(diff <= 3)
    new_mat = Matrex.set(mat, row, col, value)
    fill_row(adapter, rest, row, col + 1, new_mat)
  end

  @spec build_adjacency_matrix([integer], integer, integer, Matrex.t()) :: Matrex.t()
  def build_adjacency_matrix([], _row, _col, mat) do
    mat
  end

  def build_adjacency_matrix([adapter | adapters], row, col, mat) do
    mat = fill_row(adapter, adapters, row, col, mat)
    build_adjacency_matrix(adapters, row + 1, col + 1, mat)
  end

  @spec find_adapter_combination([integer]) :: {Matrex.t(), float}
  def find_adapter_combination(adapters) do
    mat = Matrex.zeros(length(adapters))
    adj = build_adjacency_matrix(adapters, 1, 2, mat)
    {_, count} = Enum.reduce(1..length(adapters) + 1, {adj, 0}, fn _, {acc, count} ->
      acc = Matrex.dot(acc, adj)
      count = count + Matrex.at(acc, 1, length(adapters))
      {acc, count}
    end)
    {adj, count}
  end


  def day10() do
    adapters =
      "day10_input"
      |> AdventOfCode.read_file()
      |> Enum.map(fn x ->
        {value, _} = Integer.parse(x)
        value
      end)

    additional_adapter = Enum.max(adapters) + 3
    adapters = [additional_adapter|adapters]
    adapters = Enum.sort(adapters)
    {num_ones, num_threes} = test_adapters(adapters, 0)
    part1 = num_ones * num_threes
    part2 = find_adapter_combination([0|adapters])
    {adapters, part1, part2}
  end
end

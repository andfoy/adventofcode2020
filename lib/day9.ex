defmodule AdventOfCode.Day9 do
  def read_preamble(number_list, preamble_size \\ 25) do
    read_preamble(number_list, [], preamble_size)
  end

  def read_preamble([input | _], acc, 0) do
    acc = Enum.reverse(acc)
    {acc, input}
  end

  def read_preamble([number | rest], acc, count) do
    read_preamble(rest, [number | acc], count - 1)
  end

  def subset_sum(input, limit, mode) do
    {result, _} = subset_sum(input, limit, [], mode)
    result
  end

  def subset_sum(_in, _limit, result, :restrict) when length(result) == 2 do
    {result, Enum.sum(result)}
  end

  def subset_sum([], _limit, result, _mode) do
    {result, Enum.sum(result)}
  end

  def subset_sum([weight | rest], limit, acc, mode) when weight > limit do
    subset_sum(rest, limit, acc, mode)
  end

  def subset_sum([weight | rest], limit, acc, mode) do
    {r1, v1} = subset_sum(rest, limit, acc, mode)
    {r2, v2} = subset_sum(rest, limit - weight, [weight | acc], mode)

    case v2 > v1 do
      true ->
        {r2, v2}

      false ->
        {r1, v1}
    end
  end

  def simulated_annealing(input, objective) do
    kmax = 110_000
    temp = 10_000_000
    energy_func = fn candidate -> abs(Enum.sum(candidate) - objective) end
    left_index = 0
    right_index = length(input) - 1
    best_energy = energy_func.(input)
    current_energy = best_energy
    best_solution = input
    solution = input

    minimize(
      input,
      {solution, current_energy},
      {best_solution, best_energy},
      {left_index, right_index},
      energy_func,
      kmax,
      temp
    )
  end

  def move_indices_at_random(input, left, right) do
    replace_left = :random.uniform() > 0.5
    replace_right = :random.uniform() > 0.5

    left =
      case replace_left do
        true ->
          case :random.uniform() > 0.5 do
            true -> rem(left + Enum.random(1..5), length(input))
            false -> max(left - Enum.random(1..5), 0)
          end
        false -> left
      end

    right =
      case replace_right do
        true ->
          case :random.uniform() > 0.5 do
            true -> rem(right + Enum.random(1..5), length(input))
            false -> max(right - Enum.random(1..5), 0)
          end
        false -> right
      end

    {left, right}
  end

  def minimize(_input, _current_solution, best_solution, _indices, _energy_func, 0, _temp) do
    best_solution
  end

  def minimize(
        _input,
        _current_solution,
        {best_solution, 0},
        _indices,
        _energy_func,
        _kmax,
        _temp
      ) do
    {best_solution, 0}
  end

  def minimize(
        input,
        {solution, current_energy},
        {best_solution, best_energy},
        {left, right},
        energy_func,
        kmax,
        temp
      ) do
    {left, right} = move_indices_at_random(input, left, right)
    possible_solution = Enum.slice(input, left..right)
    solution_energy = energy_func.(possible_solution)
    delta = current_energy - solution_energy

    {solution, current_energy} =
      case :math.exp(delta / temp) - :random.uniform() > 0 do
        true -> {possible_solution, solution_energy}
        false -> {solution, current_energy}
      end

    {best_solution, best_energy} =
      case current_energy < best_energy do
        true -> {solution, current_energy}
        false -> {best_solution, best_energy}
      end

    temp = 0.999999 * temp

    minimize(
        input,
        {solution, current_energy},
        {best_solution, best_energy},
        {left, right},
        energy_func,
        kmax - 1,
        temp
    )
  end

  def sliding_window_sum(numbers = [_ | rest], window_size) do
    {preamble, input} = read_preamble(numbers, window_size)
    # preamble = Enum.sort(preamble)
    case subset_sum(preamble, input, :restrict) do
      [_x, _y] -> sliding_window_sum(rest, window_size)
      _ -> {:fail, input}
    end
  end

  def subset_increasing_sum(subset, value) do
    case simulated_annealing(subset, value) do
      {seq, 0} ->
        max_part2 = Enum.max(seq)
        min_part2 = Enum.min(seq)
        max_part2 + min_part2
      _ -> subset_increasing_sum(subset, value)
    end
  end

  def day9() do
    numbers =
      "day9_input"
      |> AdventOfCode.read_file()
      |> Enum.map(fn x ->
        {value, _} = Integer.parse(x)
        value
      end)

    {:fail, part1} = sliding_window_sum(numbers, 25)
    index = Enum.find_index(numbers, fn x -> x == part1 end)
    sub_numbers = Enum.slice(numbers, 0..(index - 1))
    part2 = subset_increasing_sum(sub_numbers, part1)
    {part1, part2}
  end
end

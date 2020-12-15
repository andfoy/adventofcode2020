defmodule AdventOfCode.Day13 do
  def egcd(_, 0) do
    {1, 0}
  end

  def egcd(a, b) do
    {s, t} = egcd(b, rem(a, b))
    {t, s - div(a, b) * t}
  end

  def mod_inv(a, b) do
    {x, y} = egcd(a, b)

    case a * x + b * y == 1 do
      true -> x
      false -> nil
    end
  end

  def mod(a, m) do
    x = rem(a, m)

    case x < 0 do
      true -> x + m
      false -> x
    end
  end

  def calc_inverses([], []), do: []

  def calc_inverses([n | ns], [m | ms]) do
    case mod_inv(n, m) do
      nil -> nil
      inv -> [inv | calc_inverses(ns, ms)]
    end
  end

  def chinese_remainder(congruences) do
    {residues, modulii} = Enum.unzip(congruences)

    modpi =
      Enum.reduce(modulii, 1, fn x, acc ->
        acc * x
      end)

    crt_modulii = for m <- modulii, do: div(modpi, m)

    case calc_inverses(crt_modulii, modulii) do
      nil ->
        nil

      inverses ->
        solution =
          Enum.reduce(Enum.zip([residues, inverses, crt_modulii]), 0, fn {x, y, z}, acc ->
            acc + x * y * z
          end)

        Integer.mod(solution, modpi)
    end
  end

  def remainder(mods, remainders) do
    max = Enum.reduce(mods, fn x, acc -> x * acc end)

    Enum.zip(mods, remainders)
    |> Enum.map(fn {m, r} -> Enum.take_every(r..max, m) |> MapSet.new() end)
    |> Enum.reduce(fn set, acc -> MapSet.intersection(set, acc) end)
    |> MapSet.to_list()
  end

  def day13() do
    input =
      "day13_input"
      |> AdventOfCode.read_file()

    [header, input] = input
    {min_timestamp, _} = Integer.parse(header)

    {diff, bus_id, _, values} =
      input
      |> String.split(",")
      |> Enum.reduce({:inf, nil, 0, []}, fn x, {min_value, bus_id, seq, values} ->
        case x do
          "x" ->
            {min_value, bus_id, seq + 1, values}

          _ ->
            {value, _} = Integer.parse(x)
            integer_div = Integer.floor_div(min_timestamp, value)

            diff =
              case rem(min_timestamp, value) == 0 do
                true ->
                  0

                _ ->
                  next_value = (integer_div + 1) * value
                  next_value - min_timestamp
              end

            {new_min_value, new_bus_id} =
              case diff < min_value do
                true -> {diff, value}
                false -> {min_value, bus_id}
              end

            {new_min_value, new_bus_id, seq + 1, [{-seq, value} | values]}
        end
      end)

    part1 = diff * bus_id

    values = Enum.reverse(values)
    part2 = chinese_remainder(values)
    {part1, part2}
  end
end

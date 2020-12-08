defmodule AdventOfCode.Day8 do
  @spec add_vertex(:digraph.graph(), any) :: any
  def add_vertex(graph, vertex) do
    case :digraph.vertex(graph, vertex) do
      false ->
        :digraph.add_vertex(graph, vertex)

      {vertex, _} ->
        vertex
    end
  end

  @spec execute_op(:acc | :jmp | :nop, integer, integer, integer) :: {integer, integer}
  def execute_op(:acc, arg, instruction_ptr, acc) do
    acc = acc + arg
    instruction_ptr = instruction_ptr + 1
    {instruction_ptr, acc}
  end

  def execute_op(:nop, _, instruction_ptr, acc) do
    {instruction_ptr + 1, acc}
  end

  def execute_op(:jmp, quantity, instruction_ptr, acc) do
    instruction_ptr = instruction_ptr + quantity
    {instruction_ptr, acc}
  end

  @spec execute(integer, integer, map, :digraph.graph()) ::
          {:single | :double, integer, integer, :digraph.graph()}
  def execute(instruction_ptr, acc, program, graph)
      when not is_map_key(program, instruction_ptr) do
    {:single, instruction_ptr, acc, graph}
  end

  def execute(instruction_ptr, acc, program, graph) do
    %{^instruction_ptr => {count, {opcode, arg}}} = program

    case count == 1 do
      true ->
        {:double, instruction_ptr, acc, graph}

      false ->
        count = count + 1
        this_instruction = add_vertex(graph, instruction_ptr)
        program = Map.put(program, instruction_ptr, {count, {opcode, arg}})
        {instruction_ptr, acc} = execute_op(opcode, arg, instruction_ptr, acc)
        next_instruction = add_vertex(graph, instruction_ptr)
        :digraph.add_edge(graph, this_instruction, next_instruction)
        execute(instruction_ptr, acc, program, graph)
    end
  end

  def fix_cycle(graph, program, [ptr | rest]) do
    case Map.get(program, ptr) do
      {_, {:nop, arg}} ->
        new_program = Map.put(program, ptr, {0, {:jmp, arg}})

        case execute(0, 0, new_program, :digraph.new()) do
          {:single, _, acc, _} -> acc
          {:double, _, _, _} -> fix_cycle(graph, program, rest)
        end

      {_, {:jmp, arg}} ->
        new_program = Map.put(program, ptr, {0, {:nop, arg}})

        case execute(0, 0, new_program, :digraph.new()) do
          {:single, _, acc, _} -> acc
          {:double, _, _, _} -> fix_cycle(graph, program, rest)
        end

      _ ->
        fix_cycle(graph, program, rest)
    end
  end

  def day8() do
    {_, program} =
      "day8_input"
      |> AdventOfCode.read_file()
      |> Enum.reduce({0, %{}}, fn x, {ptr, acc} ->
        [instr, count] = String.split(x)
        instr = String.to_atom(instr)
        {count, _} = Integer.parse(count)
        acc = Map.put(acc, ptr, {0, {instr, count}})
        {ptr + 1, acc}
      end)

    {:double, ptr, part1, graph} = execute(0, 0, program, :digraph.new())
    cycle = :digraph.get_cycle(graph, ptr)
    part2 = fix_cycle(graph, program, cycle)
    {part1, part2, ptr, graph}
  end
end

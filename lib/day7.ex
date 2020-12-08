defmodule AdventOfCode.Day7 do
  @spec add_get_node({atom, atom}, :digraph.graph()) :: {:digraph.graph(), :digraph.vertex()}
  def add_get_node(node_key, graph) do
    case :digraph.vertex(graph, node_key) do
      false ->
        vertex = :digraph.add_vertex(graph, node_key)
        {graph, vertex}

      {vertex, _} ->
        {graph, vertex}
    end
  end

  @spec add_edges({atom, atom}, {atom, atom}, integer(), :digraph.graph()) :: :digraph.graph()
  def add_edges(parent_node, this_node, quantity, graph) do
    {graph, parent_node} = add_get_node(parent_node, graph)
    {graph, this_node} = add_get_node(this_node, graph)
    :digraph.add_edge(graph, parent_node, this_node, quantity)
    graph
  end

  @spec parse_contents(:digraph.vertex(), :digraph.graph(), [atom | integer]) :: :digraph.graph()
  def parse_contents(_, graph, []) do
    graph
  end

  def parse_contents(_, graph, [:no | _]) do
    graph
  end

  def parse_contents(parent_node, graph, [quantity, adjective, color, bags | rest])
      when bags in [:"bags,", :"bags.", :"bag,", :"bag."] do
    this_node = {adjective, color}
    graph = add_edges(parent_node, this_node, quantity, graph)
    parse_contents(parent_node, graph, rest)
  end

  @spec convert_atom_integer(binary) :: atom | integer
  def convert_atom_integer(str) do
    case Integer.parse(str) do
      {value, _} -> value
      :error -> String.to_atom(str)
    end
  end

  @spec gold_closure(:digraph.graph()) :: [:digraph.vertex()]
  def gold_closure(graph) do
    gold_neighbors = :digraph.in_neighbours(graph, {:shiny, :gold})
    closure(graph, gold_neighbors, MapSet.new())
  end

  @spec closure(:digraph.graph(), [:digraph.vertex()], MapSet.t()) :: [:digraph.vertex()]
  def closure(_, [], acc) do
    Enum.to_list(acc)
  end

  def closure(graph, [node | nodes], acc) do
    node_out = :digraph.in_neighbours(graph, node)
    closure(graph, node_out ++ nodes, MapSet.put(acc, node))
  end

  @spec count_bags_closure(:digraph.graph(), :digraph.vertex()) :: integer
  def count_bags_closure(graph, node) do
    out_edges = :digraph.out_edges(graph, node)
    count_bags(graph, out_edges, 0)
  end

  @spec count_bags(:digraph.graph(), [:digraph.edge()], integer()) :: integer()
  def count_bags(_, [], count) do
    count
  end

  def count_bags(graph, [edge | edges], count) do
    {_, _from, to, quantity} = :digraph.edge(graph, edge)
    count = count + quantity
    to_count = count_bags_closure(graph, to)
    count = count + quantity * to_count
    count_bags(graph, edges, count)
  end

  def day7() do
    {_, graph} =
      "day7_input"
      |> AdventOfCode.read_file()
      |> Enum.map_reduce(:digraph.new(), fn entry, graph ->
        components =
          entry
          |> String.split()
          |> Enum.map(&convert_atom_integer/1)

        [adjective, color, :bags, :contain | contents] = components
        this_node = {adjective, color}

        graph = parse_contents(this_node, graph, contents)
        {contents, graph}
      end)

    part1 =
      graph
      |> gold_closure()
      |> length()

    part2 = count_bags_closure(graph, {:shiny, :gold})
    {part1, part2}
  end
end

defmodule AdventOfCode do
  @moduledoc """
  Documentation for `AdventOfCode`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> AdventOfCode.hello()
      :world

  """
  def hello do
    :world
  end

  def read_file(file) do
    :advent_of_code
      |> :code.priv_dir()
      |> Path.join(file)
      |> File.read!()
      |> String.split(["\n"])
  end

  def boolean_to_integer(true), do: 1
  def boolean_to_integer(false), do: 0
end

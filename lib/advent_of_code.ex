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

  @spec read_file(
          binary
          | maybe_improper_list(
              binary | maybe_improper_list(any, binary | []) | char,
              binary | []
            )
        ) :: [binary]
  def read_file(file) do
    :advent_of_code
    |> :code.priv_dir()
    |> Path.join(file)
    |> File.read!()
    |> String.split(["\n"])
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

  @spec boolean_to_integer(boolean) :: 0 | 1
  def boolean_to_integer(true), do: 1
  def boolean_to_integer(false), do: 0
end

defmodule Stat do
  @moduledoc false

  def run(function) do
    Bench.mark(function)

    [
      Bench.mark(function),
      Bench.mark(function),
      Bench.mark(function),
      Bench.mark(function),
      Bench.mark(function),
      Bench.mark(function),
      Bench.mark(function)
    ]
    |> make_average_stat()
  end

  def make_average_stat([first | []]), do: first

  def make_average_stat([first | rest]) do
    {_, avg} =
    rest
    |> Enum.reduce({1, first}, fn next, {weight, current} ->
      {
        weight + 1,
        current
        |> Enum.zip(next)
        |> Enum.map(fn {{n, r, current_time, current_mem}, {n, r, next_time, next_mem}} ->
          {
            n,
            r,
            (current_time * weight + next_time) / (weight+1),
            (current_mem * weight + next_mem) / (weight+1)
          }
        end)
      }
    end)

    avg
  end
end

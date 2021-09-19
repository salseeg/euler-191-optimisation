defmodule Mix.Tasks.Bench do
  @moduledoc """
    Here to describe all options
  """

  use Mix.Task

  @shortdoc "Benchmark "
  @impl Mix.Task

  @algo %{
    "bruteforce" => &Bruteforce.run/1,
    "bruteforce.string" => &Bruteforce.String.run/1,
    "bruteforce.early" => &Bruteforce.EarlyFilter.run/1,
    "recursion" => &Recursion.run/1,
    "recursion.checks" => &Recursion.Checks.run/1,
    "recursion.chains" => &Recursion.Chains.run/1,
    "recursion.cache" => &Recursion.Cache.run/1,
    "buckets" => &Buckets.run/1,
    "buckets.factor" => &Buckets.Factor.run/1
  }

  def run([key]) do
    process(Map.fetch!(@algo, key))
  end

  def process(fun) do
    fun
    |> Stat.run()
    |> Enum.map(fn {n, _, t, m} ->
      {n, trunc(t / 1) / 1_000_000, trunc(m * 1000 / 1024 / 1024) / 1000}
    end)
    |> pretty_print_one()
  end

  def pretty_print_one(res) do
    res
    |> Enum.reverse()
    |> Enum.each(fn {n, time, mem} ->
      IO.puts("\t#{n}:\t\t#{time} s\t#{mem} Mb")
    end)
  end
end

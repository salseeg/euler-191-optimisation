defmodule Mix.Tasks.Bench do
  @moduledoc """
    Here to describe all options
  """

  use Mix.Task

  @shortdoc "Benchmark "
  @impl Mix.Task
  def run(["bruteforce"]), do: bruteforce()
  def run(["bruteforce.string"]), do: bruteforce_string()
  def run(["bruteforce.early"]), do: bruteforce_early()
  def run(["recursion"]), do: recursion()
  def run(["recursion.checks"]), do: recursion_checks()
  def run(["recursion.chains"]), do: recursion_chains()
  def run(["recursion.cache"]), do: recursion_cache()
  def run(["buckets"]), do: buckets()
  def run(["buckets.factor"]), do: buckets_factor()
  def run(["buckets.multi"]), do: buckets_multi()

  def buckets_multi do
    fn n ->
      Buckets.Multi.run(n)
    end
    |> process
  end


  def buckets_factor do
    fn n ->
      Buckets.Factor.run(n)
    end
    |> process
  end


  def buckets do
    fn n ->
      Buckets.run(n)
    end
    |> process
  end

  def recursion_cache do
    fn n ->
      Recursion.Cache.live_on_time(n)
    end
    |> process
  end

  def recursion_chains do
    fn n ->
      Recursion.Chain.live_on_time(n)
    end
    |>process
  end

  def recursion_checks do
    fn n ->
      Recursion.Checks.live(n)
    end
    |> process
  end

  def recursion() do
    fn n ->
      Recursion.live(n)
    end
    |> process
  end

  def bruteforce_early() do
    fn n ->
      n
      |> Bruteforce.EarlyFilter.generate()
      |> Enum.count()
    end
    |> process
  end


  def bruteforce do
    fn n ->
      n
      |> Bruteforce.generate()
      |> Bruteforce.filter_out()
      |> Enum.count()
    end
    |> process
  end

  def bruteforce_string do
    fn n ->
      n
      |> Bruteforce.generate()
      |> Bruteforce.filter_out_string()
      |> Enum.count()
    end
    |> process
  end

  def pretty_print_one(res) do
    res
    |> Enum.reverse()
    |> Enum.each(fn {n, time, mem} ->
      IO.puts("\t#{n}:\t\t#{time} s\t#{mem} Mb")
    end)
  end

  def process(fun) do
    fun
    |> Stat.run()
    |> Enum.map(fn {n, _, t, m} ->
      {n, trunc(t / 1) / 1000000, trunc(m * 1000 / 1024 / 1024) / 1000}
    end)
    |> pretty_print_one()
  end
end

defmodule Mix.Tasks.Bench do
  @moduledoc """
    Here to describe all options
  """

  use Mix.Task

  @shortdoc "Benchmark "
  @impl Mix.Task
  def run(["bruteforce"]), do: bruteforce()
  def run(["bruteforce.string"]), do: bruteforce_string()

  def run(args) do
    args |> IO.inspect()
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
      {n, trunc(t / 1000) / 1000, trunc(m * 1000 / 1024 / 1024) / 1000}
    end)
    |> pretty_print_one()
  end
end

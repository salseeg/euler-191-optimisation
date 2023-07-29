defmodule Mix.Tasks.Calc do
  @moduledoc """
    Here to describe all options
  """

  use Mix.Task

  @shortdoc "Benchmark "
  @impl Mix.Task

  def run([key, n_str]) do
    n = String.to_integer(n_str)
    algo = Opt191.algo() |> Map.fetch!(key)
    res = algo.(n)

    [
      "Amount of prize strings for ",
      inspect(n),
      " days\n",
      inspect(res),
      "\n\n"
    ]
    |> IO.puts()
  end

  def run(_) do
    algos =
      Opt191.algo()
      |> Map.keys()
      |> Enum.sort()
      |> Enum.map_join("\n", &("        " <> &1))

    """

    mix calc <algo> <n>
        n - is the number of days
        algo - one of:
    #{algos}
    """
    |> IO.puts()
  end
end

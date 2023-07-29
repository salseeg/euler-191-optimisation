defmodule Bench do
  @moduledoc "Benchmarking helpers"

  @ms_in_second 1_000_000
  @run_timeout 2 * @ms_in_second
  @series [1, 10, 14, 20, 30, 35, 100, 365, 3650, 36500, 365_000]

  @doc """
    Runs a function, tracking time to execute and memory used
  """
  def mark(function, series \\ @series, timeout \\ @run_timeout, acc \\ [])
  def mark(_, [], _, acc), do: acc

  def mark(function, [n | rest_n], timeout, acc) do
    {time, result, mem} =
      fn -> track(function, n) end
      |> Task.async()
      |> Task.await(:infinity)

    if time < timeout do
      mark(function, rest_n, timeout, [{n, result, time, mem} | acc])
    else
      [{n, result, time, mem} | acc]
    end
  end

  defp track(function, n) do
    {time, result} = :timer.tc(function, [n])
    mem = get_memory()

    {time, result, mem}
  end

  defp get_memory() do
    get_memory(:process_mem) + get_memory(:vm_binaries)
  end

  defp get_memory(:process_mem) do
    word_size = :erlang.system_info(:wordsize)
    {:memory, words} = :erlang.process_info(self(), :memory)

    words * word_size
  end

  defp get_memory(:vm_binaries) do
    {:binary, data} = Process.info(self(), :binary)

    data
    |> Enum.map(fn {_id, size, _count} -> size end)
    |> Enum.sum()
  end
end

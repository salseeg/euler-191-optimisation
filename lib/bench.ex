defmodule Bench do
  @ms_in_second 1_000_000

  def series(), do: [1, 10, 14, 20, 30, 35, 365, 36500, 365_000]
  def run_time(), do: 1.5 * @ms_in_second

  def mark(function, series \\ series(), timeout \\ run_time(), acc \\ [])
  def mark(_, [], _, acc), do: acc

  def mark(function, [n | rest_n], timeout, acc) do
    {time, result, mem} =
      fn -> process(function, n) end
      |> Task.async()
      |> Task.await(:infinity)

    if time < timeout do
      mark(function, rest_n, timeout, [{n, result, time, mem} | acc])
    else
      [{n, result, time, mem} | acc]
    end
  end

  def process(function, n) do
    {time, result} = :timer.tc(function, [n])
    mem = get_memory()

    {time, result, mem}
  end

  def get_memory() do
    get_memory(:process_mem) + get_memory(:vm_binaries)
  end

  def get_memory(:process_mem) do
    word_size = :erlang.system_info(:wordsize)
    {:memory, words} = :erlang.process_info(self(), :memory)

    words * word_size
  end

  def get_memory(:vm_binaries) do
    {:binary, data} = Process.info(self(), :binary)

    data
    |> Enum.map(fn {_id, size, _count} -> size end)
    |> Enum.sum()
  end
end

defmodule Recursion.Cache do
  def live_on_time(0), do: 1

  def live_on_time(n),
      do:
        cached({:o, n}, fn ->
          live_on_time(n - 1) + live_once_late(n - 1) + live_once_absent(n - 1)
        end)

  def live_once_late(0), do: 1

  def live_once_late(n),
      do: cached({:l, n}, fn -> live_once_late(n - 1) + live_once_late_once_absent(n - 1) end)

  def live_once_absent(0), do: 1

  def live_once_absent(n),
      do:
        cached({:a, n}, fn ->
          live_on_time(n - 1) + live_once_late(n - 1) + live_twice_absent(n - 1)
        end)

  def live_once_late_once_absent(0), do: 1

  def live_once_late_once_absent(n),
      do: cached({:la, n}, fn -> live_once_late(n - 1) + live_once_late_twice_absent(n - 1) end)

  def live_twice_absent(0), do: 1

  def live_twice_absent(n),
      do: cached({:aa, n}, fn -> live_on_time(n - 1) + live_once_late(n - 1) end)

  def live_once_late_twice_absent(0), do: 1
  def live_once_late_twice_absent(n), do: cached({:laa, n}, fn -> live_once_late(n - 1) end)

  def cached(key, function) do
    case Process.get(key) do
      nil ->
        value = function.()
        Process.put(key, value)
        value

      value ->
        value
    end
  end
end
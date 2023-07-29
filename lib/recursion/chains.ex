defmodule Recursion.Chains do
  def run(n), do: live_on_time(n)

  def live_on_time(0), do: 1
  def live_on_time(n), do: live_on_time(n - 1) + live_once_late(n - 1) + live_once_absent(n - 1)

  def live_once_late(0), do: 1
  def live_once_late(n), do: live_once_late(n - 1) + live_once_late_once_absent(n - 1)

  def live_once_absent(0), do: 1

  def live_once_absent(n),
    do: live_on_time(n - 1) + live_once_late(n - 1) + live_twice_absent(n - 1)

  def live_once_late_once_absent(0), do: 1

  def live_once_late_once_absent(n),
    do: live_once_late(n - 1) + live_once_late_twice_absent(n - 1)

  def live_twice_absent(0), do: 1
  def live_twice_absent(n), do: live_on_time(n - 1) + live_once_late(n - 1)

  def live_once_late_twice_absent(0), do: 1
  def live_once_late_twice_absent(n), do: live_once_late(n - 1)
end

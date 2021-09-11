defmodule Recursion.Checks do
  def live(n, late \\ 0, absent \\ 0)
  def live(0, _, _), do: 1

  def live(n, late, absent) do
    live_on_time(n - 1, late) + live_late(n - 1, late) + live_absent(n - 1, late, absent)
  end

  def live_on_time(n, late), do: live(n, late)
  def live_late(n, 0), do: live(n, 1)
  def live_late(_, _), do: 0
  def live_absent(n, late, 0), do: live(n, late, 1)
  def live_absent(n, late, 1), do: live(n, late, 2)
  def live_absent(_, _, _), do: 0
end
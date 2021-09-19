defmodule Recursion do
  def run(n), do: live(n)

  def live(n, late \\ 0, absent \\ 0)
  def live(_, 2, _), do: 0
  def live(_, _, 3), do: 0
  def live(0, _, _), do: 1

  def live(n, late, absent) do
    live_on_time(n - 1, late) + live_late(n - 1, late) + live_absent(n - 1, late, absent)
  end

  def live_on_time(n, late), do: live(n, late)
  def live_late(n, late), do: live(n, late + 1)
  def live_absent(n, late, absent), do: live(n, late, absent + 1)
end

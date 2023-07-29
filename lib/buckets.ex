defmodule Buckets do
  def run(n, counters \\ {1, 0, 0, 0, 0, 0})
  def run(0, {o, a, aa, l, la, laa}), do: o + a + aa + l + la + laa

  def run(n, {o, a, aa, l, la, laa}),
    do:
      run(n - 1, {
        o + a + aa,
        o,
        a,
        o + a + aa + l + la + laa,
        l,
        la
      })
end

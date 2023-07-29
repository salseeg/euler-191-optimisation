defmodule Buckets.Factor do
  def count(0, factors), do: factors

  def count(n, {o, a, aa, l, la, laa}),
    do:
      count(n - 1, {
        o + a + aa,
        o,
        a,
        o + a + aa + l + la + laa,
        l,
        la
      })

  def run(n), do: run(n, trunc(n / 32 + 2))

  def run(n, size) when n <= size do
    {o, a, aa, l, la, laa} = count(n, {1, 0, 0, 0, 0, 0})
    o + a + aa + l + la + laa
  end

  def run(n, size) do
    {times, reminder} = split(n, size)

    initial = count(reminder, {1, 0, 0, 0, 0, 0})

    factors = {
      count(size, {1, 0, 0, 0, 0, 0}),
      count(size, {0, 1, 0, 0, 0, 0}),
      count(size, {0, 0, 1, 0, 0, 0}),
      count(size, {0, 0, 0, 1, 0, 0}),
      count(size, {0, 0, 0, 0, 1, 0}),
      count(size, {0, 0, 0, 0, 0, 1})
    }

    {o, a, aa, l, la, laa} = apply_factors(initial, times, factors)
    o + a + aa + l + la + laa
  end

  def split(n, size) do
    times = div(n, size)
    reminder = rem(n, size)

    if reminder == 0 do
      {times - 1, size}
    else
      {times, reminder}
    end
  end

  def apply_factors(initial, 0, _), do: initial

  def apply_factors({o, a, aa, l, la, laa}, n, {f_o, f_a, f_aa, f_l, f_la, f_laa} = factors) do
    {o_o, o_a, o_aa, o_l, o_la, o_laa} = f_o
    {a_o, a_a, a_aa, a_l, a_la, a_laa} = f_a
    {aa_o, aa_a, aa_aa, aa_l, aa_la, aa_laa} = f_aa
    {l_o, l_a, l_aa, l_l, l_la, l_laa} = f_l
    {la_o, la_a, la_aa, la_l, la_la, la_laa} = f_la
    {laa_o, laa_a, laa_aa, laa_l, laa_la, laa_laa} = f_laa

    {
      o * o_o + a * a_o + aa * aa_o + l * l_o + la * la_o + laa * laa_o,
      o * o_a + a * a_a + aa * aa_a + l * l_a + la * la_a + laa * laa_a,
      o * o_aa + a * a_aa + aa * aa_aa + l * l_aa + la * la_aa + laa * laa_aa,
      o * o_l + a * a_l + aa * aa_l + l * l_l + la * la_l + laa * laa_l,
      o * o_la + a * a_la + aa * aa_la + l * l_la + la * la_la + laa * laa_la,
      o * o_laa + a * a_laa + aa * aa_laa + l * l_laa + la * la_laa + laa * laa_laa
    }
    |> apply_factors(n - 1, factors)
  end
end

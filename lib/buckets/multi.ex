defmodule Buckets.Multi do
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

  def run(n), do: run(n, trunc(n / 40 + 2))

  def run(n, size) when n <= size do
    {o, a, aa, l, la, laa} = count(n, {1, 0, 0, 0, 0, 0})
    o + a + aa + l + la + laa
  end

  def run(n, size) do
    {times, reminder} = split(n, size)

    task_initial = Task.async(fn -> count(reminder, {1, 0, 0, 0, 0, 0}) end)

    task_o = Task.async(fn -> count(size, {1, 0, 0, 0, 0, 0}) end)
    task_a = Task.async(fn -> count(size, {0, 1, 0, 0, 0, 0}) end)
    task_aa = Task.async(fn -> count(size, {0, 0, 1, 0, 0, 0}) end)
    task_l = Task.async(fn -> count(size, {0, 0, 0, 1, 0, 0}) end)
    task_la = Task.async(fn -> count(size, {0, 0, 0, 0, 1, 0}) end)
    task_laa = Task.async(fn -> count(size, {0, 0, 0, 0, 0, 1}) end)

    initial = Task.await(task_initial, :infinity)

    "*" |> IO.inspect()

    factors = {
      Task.await(task_o, :infinity),
      Task.await(task_a, :infinity),
      Task.await(task_aa, :infinity),
      Task.await(task_l, :infinity),
      Task.await(task_la, :infinity),
      Task.await(task_laa, :infinity)
    }

    DateTime.utc_now() |> IO.inspect()

    #    make_table(:main, initial)

    build_vectors(factors)

    {o, a, aa, l, la, laa} = apply_factors(initial, times)

    DateTime.utc_now() |> IO.inspect(label: "applied")
    kill_vectors()
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

  def build_vectors({f_o, f_a, f_aa, f_l, f_la, f_laa} = _factors) do
    {o_o, o_a, o_aa, o_l, o_la, o_laa} = f_o
    {a_o, a_a, a_aa, a_l, a_la, a_laa} = f_a
    {aa_o, aa_a, aa_aa, aa_l, aa_la, aa_laa} = f_aa
    {l_o, l_a, l_aa, l_l, l_la, l_laa} = f_l
    {la_o, la_a, la_aa, la_l, la_la, la_laa} = f_la
    {laa_o, laa_a, laa_aa, laa_l, laa_la, laa_laa} = f_laa

    make_table(:o_vec, {o_o, a_o, aa_o, l_o, la_o, laa_o})
    make_table(:a_vec, {o_a, a_a, aa_a, l_a, la_a, laa_a})
    make_table(:aa_vec, {o_aa, a_aa, aa_aa, l_aa, la_aa, laa_aa})
    make_table(:l_vec, {o_l, a_l, aa_l, l_l, la_l, laa_l})
    make_table(:la_vec, {o_la, a_la, aa_la, l_la, la_la, laa_la})
    make_table(:laa_vec, {o_laa, a_laa, aa_laa, l_laa, la_laa, laa_laa})
  end

  def kill_vectors() do
    :ets.delete(:o_vec)
    :ets.delete(:a_vec)
    :ets.delete(:aa_vec)
    :ets.delete(:l_vec)
    :ets.delete(:la_vec)
    :ets.delete(:laa_vec)
  end

  @key :some_key
  def make_table(key, value) do
    :ets.new(key, [:named_table])
    :ets.insert(key, {@key, value})
  end

  def get_table(key) do
    :ets.lookup(key, @key)
    |> Enum.at(0)
    |> elem(1)
  end

  def apply_factors(initial, 0), do: initial

  def apply_factors(vec, n) do
    o_task = Task.async(fn -> prod_sum(vec, :o_vec) end)
    a_task = Task.async(fn -> prod_sum(vec, :a_vec) end)
    aa_task = Task.async(fn -> prod_sum(vec, :aa_vec) end)
    l_task = Task.async(fn -> prod_sum(vec, :l_vec) end)
    la_task = Task.async(fn -> prod_sum(vec, :la_vec) end)
    laa_task = Task.async(fn -> prod_sum(vec, :laa_vec) end)

    {
      Task.await(o_task, :infinity),
      Task.await(a_task, :infinity),
      Task.await(aa_task, :infinity),
      Task.await(l_task, :infinity),
      Task.await(la_task, :infinity),
      Task.await(laa_task, :infinity)
    }
    |> apply_factors(n - 1)
  end

  def prod_sum({a, b, c, d, e, f}, key) do
    {u, v, w, x, y, z} = get_table(key)

    a * u + b * v + c * w + d * x + e * y + f * z
  end
end

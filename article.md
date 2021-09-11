# Euler 191

## The task

A particular school offers cash rewards to children with good attendance and punctuality. If they are absent for three consecutive days or late on more than one occasion then they forfeit their prize.

During an n-day period a trinary string is formed for each child consisting of L's (late), O's (on time), and A's (absent).

Although there are eighty-one trinary strings for a 4-day period that can be formed, exactly forty-three strings would lead to a prize:

```
OOOO OOOA OOOL OOAO OOAA OOAL OOLO OOLA OAOO OAOA
OAOL OAAO OAAL OALO OALA OLOO OLOA OLAO OLAA AOOO
AOOA AOOL AOAO AOAA AOAL AOLO AOLA AAOO AAOA AAOL
AALO AALA ALOO ALOA ALAO ALAA LOOO LOOA LOAO LOAA
LAOO LAOA LAAO
```

How many "prize" strings exist over a 30-day period?

## Preparation

To tackle the task efficiency we would need a tool to bechmark our solution as well as show results and execution time.

Elixir/Erlang has `:timer.tc()` function that does the job. It takes anonymous functions and list of arguments to be passed into it.
`:timer.tc` returns a tuple of execution time and value returned by anonymous function.

A solution won't get optimal on first try. Let's add calculation of smaller *n* and limit execution time.
If calucation take less than 10s it will proceed to next *n*.
This way our *n* series would be `1, 2, 3, 4, 10, 20, 30`

```elixir
defmodule Bench do
  @microseconds 1_000_000

  def series(), do: [1, 2, 3, 4, 10, 15, 20, 30]

  def run_time(), do: 10 * @microseconds

  def mark(function, callback \\ & &1, series \\ series(), timeout \\ run_time())
  def mark(_, _, [], _), do: :series_stop

  def mark(function, callback, [n | rest_n], timeout) do
    {time, result} = :timer.tc(function, [n])
    IO.puts("Run for #{n} makes #{result} and takes #{time / @microseconds} s")

    callback.({n, time})

    if time < timeout do
      mark(function, callback, rest_n, timeout)
    else
      {:time_stop, {n, time}}
    end
  end

  def times_over({n, time}) do
    fn
      {^n, new_time} -> "It is #{time / new_time}x faster" |> IO.puts()
      _ -> :ok
    end
  end
end
```

Let's check how it works on a dumb example. Let it wait for n seconds.

```elixir
fn n ->
  :timer.sleep(n * 1000)
  n
end
|> Bench.mark()
```

## Brute force

The first idea that comes is to:

* generate all possible strings for given *n*
* filter out bad ones
* count good ones

```elixir
defmodule Bruteforce do
  @options ["O", "L", "A"]

  def generate(n, list \\ [""])
  def generate(0, list), do: list

  def generate(n, list) do
    new_list =
      @options
      |> Enum.flat_map(fn option ->
        list
        |> Enum.map(fn item -> option <> item end)
      end)

    generate(n - 1, new_list)
  end

  def filter_out(list),
    do:
      list
      |> Enum.reject(fn item ->
        cond do
          # item |> String.match?(~r/AAA/) -> true
          # item |> String.match?(~r/L[OA]*L/) -> true
          item |> String.contains?("AAA") -> true
          String.length(item) > 1 + String.length(item |> String.replace("L", "")) -> true
          true -> false
        end
      end)
end
```

Trying this approach

```elixir
{_, bruteforce_mark} =
  fn n ->
    n
    |> Bruteforce.generate()
    |> Bruteforce.filter_out()
    |> Enum.count()
  end
  |> Bench.mark()
```

This does not go well. Memory consumption gets high. It looks like we are genereting a lot of options that we are rejecting after.
Lets filter out at them generation step.

It may look as too much filttering but lets give it a try

```elixir
defmodule Bruteforce.EarlyFilter do
  @options ["O", "L", "A"]

  def generate(n, list \\ [""])
  def generate(0, list), do: list

  def generate(n, list) do
    new_list =
      @options
      |> Enum.flat_map(fn option ->
        list
        |> Enum.map(fn item -> option <> item end)
        |> filter_out()
      end)

    generate(n - 1, new_list)
  end

  def filter_out(list),
    do:
      list
      |> Enum.reject(fn item ->
        cond do
          item |> String.contains?("AAA") -> true
          String.length(item) > 1 + String.length(item |> String.replace("L", "")) -> true
          true -> false
        end
      end)
end
```

By adding `filter_out()` into generation pipe we preventing options generation for already failed sequence.

So let's check.

```elixir
{_, bruteforce_early_mark} =
  fn n ->
    n
    |> Bruteforce.EarlyFilter.generate()
    |> Enum.count()
  end
  |> Bench.mark(Bench.times_over(bruteforce_mark))
```

This gives us 38x speedup.

But memory usage still high.

## Recursion

Let's get rid off string list to address memory usage.

We need to think about the task with different angle.

Let our function live the day and split up in recursion with each of possible option skipping invalid ones.
Late(L) counter and sequential absent(A) counter will be introduced to keep track of valid path.

```elixir
defmodule Recursion do
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

{_, recursion_mark} =
  fn n ->
    Recursion.live(n)
  end
  |> Bench.mark(Bench.times_over(bruteforce_early_mark))
```

This gives us 601x speedup

What can we improve here?
We might shift validity checking into functions increasing those counters.
This way we skip checking unchanged values.

```elixir
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

{_, recrsion_checks_mark} =
  fn n ->
    Recursion.Checks.live(n)
  end
  |> Bench.mark(Bench.times_over(recursion_mark))
```

This gives 1.23x speedup. Not much, but gives a hint where to go.

We might encode counters into calls chain.

```elixir
defmodule Recursion.Chain do
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

{_, recursion_chain_mark} =
  |> Bench.mark(Bench.times_over(recrsion_checks_mark))
```

caching

```elixir
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
        # IO.put '.'
        value = function.()
        Process.put(key, value)
        value

      # |> IO.inspect()
      value ->
        value
    end
  end
end

{_, recursion_cache_mark} =
  fn n ->
    Recursion.Cache.live_on_time(n)
  end
  |> Bench.mark(
    Bench.times_over(recursion_chain_mark),
    [10, 20, 30, 365, 3650, 36500, 365_000],
    100_000
  )
```

This makes another 2.22x speedup.

Here we have `live_once_late_twice_absent()` tail call optimized.
The 5 rest functions keep their intermediate state in the stack.
How can we make all of them tail call optimized? We need a way to move whole state into arguments to get rid of multiple recursion

## Quantum leap or Queueing theory (buckets)

If we look on `Recursion.Chain` module we clearly see as control flow moves between 6 functions...

```elixir
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

{_, buckets_mark} =
  fn n ->
    Buckets.run(n)
  end
  |> Bench.mark(Bench.times_over(recursion_cache_mark), [10, 20, 30, 365, 3650, 36500, 365_000])
```

get factors

```elixir
defmodule Buckets.Factor do
  @size 10_000

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

  def run(n) when n <= @size do
    {o, a, aa, l, la, laa} = count(n, {1, 0, 0, 0, 0, 0})
    o + a + aa + l + la + laa
  end

  def run(n) do
    {times, reminder} = split(n, @size)

    initial = count(reminder, {1, 0, 0, 0, 0, 0})

    factors = {
      count(@size, {1, 0, 0, 0, 0, 0}),
      count(@size, {0, 1, 0, 0, 0, 0}),
      count(@size, {0, 0, 1, 0, 0, 0}),
      count(@size, {0, 0, 0, 1, 0, 0}),
      count(@size, {0, 0, 0, 0, 1, 0}),
      count(@size, {0, 0, 0, 0, 0, 1})
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

{_, buckets_factor_mark} =
  fn n ->
    Buckets.Factor.run(n)
  end
  |> Bench.mark(Bench.times_over(buckets_mark), [10, 20, 30, 365, 365_0, 365_00, 365_000])
```

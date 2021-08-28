defmodule Opt191Test do
  use ExUnit.Case
  doctest Opt191

  test "greets the world" do
    assert Opt191.hello() == :world
  end

  test "test timer" do
    {took, _} = :timer.tc(fn -> :timer.sleep(100) end)

    assert took > 100_000
    assert took < 101_000
  end

  test "benchmark test" do
    sample = fn n -> :timer.sleep(100 * n); n+1 end

    assert [
             {150, 151, c},
             {15, 16, b},
             {1, 2, a},
           ] = Bench.mark(sample, [1, 15, 150])

    assert a > 100_000
    assert a < 101_000

    assert b > 1_500_000
    assert b < 1_501_000

    assert c > 15_000_000
    assert c < 15_001_000
  end

  def known_results() do
    {[1, 2, 4, 5, 7, 10],
      [
        {10, 3536},
        {7, 418},
        {5, 94},
        {4, 43},
        {2, 8},
        {1, 3}
      ]
    }
  end

  test "bruteforce" do

    {sequence, correct} = known_results()
    result = Bench.mark(fn n -> Bruteforce.generate(n) |> Bruteforce.filter_out() |> Enum.count end, sequence)

    Enum.zip(correct, result)
    |> Enum.each(fn {{correct_n, correct_res}, {actual_n, actual_res, _}} ->
      assert correct_n == actual_n
      assert correct_res == actual_res
    end)

  end

  @tag timeout: :infinity
  @tag :focus
  test "stats" do
    Stat.run(fn n -> Bruteforce.generate(n) |> Bruteforce.filter_out() |> Enum.count end)
    |> IO.inspect()
  end

end

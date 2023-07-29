defmodule Opt191 do
  @moduledoc """
  Documentation for `Opt191`.
  """

  def algo do
    %{
      "bruteforce" => &Bruteforce.run/1,
      "bruteforce.string" => &Bruteforce.String.run/1,
      "bruteforce.early" => &Bruteforce.EarlyFilter.run/1,
      "recursion" => &Recursion.run/1,
      "recursion.checks" => &Recursion.Checks.run/1,
      "recursion.chains" => &Recursion.Chains.run/1,
      "recursion.cache" => &Recursion.Cache.run/1,
      "buckets" => &Buckets.run/1,
      "buckets.factor" => &Buckets.Factor.run/1
    }
  end
end

defmodule Bruteforce.Regexp do
  @options ["O", "L", "A"]

  def run(n), do: n |> generate |> filter_out_string |> Enum.count()

  def generate(n, list \\ [""])
  def generate(0, list), do: list

  def generate(n, list) do
    new_list =
      Enum.flat_map(@options, fn option ->
        Enum.map(list, fn item -> option <> item end)
      end)

    generate(n - 1, new_list)
  end

  def filter_out_string(list) do
    Enum.reject(list, fn item ->
      cond do
        String.match?(item, ~r/AAA/) -> true
        String.match?(item, ~r/L[OA]*L/) -> true
        true -> false
      end
    end)
  end
end

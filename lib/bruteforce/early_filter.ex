defmodule Bruteforce.EarlyFilter do
  @options ["O", "L", "A"]

  def run(n), do: n |> generate |> Enum.count()

  def generate(n, list \\ [""])
  def generate(0, list), do: list

  def generate(n, list) do
    new_list =
      Enum.flat_map(@options, fn option ->
        list
        |> Enum.map(fn item -> option <> item end)
        |> filter_out()
      end)

    generate(n - 1, new_list)
  end

  def filter_out(list) do
    Enum.reject(list, fn item ->
      cond do
        String.contains?(item, "AAA") -> true
        String.length(item) > 1 + String.length(item |> String.replace("L", "")) -> true
        true -> false
      end
    end)
  end
end

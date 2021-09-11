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

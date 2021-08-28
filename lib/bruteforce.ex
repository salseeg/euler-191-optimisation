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
          item |> String.match?(~r/AAA/) -> true
          item |> String.match?(~r/L[OA]*L/) -> true
          true -> false
        end
      end)

  def filter_out_string(list),
    do:
      list
      |> Enum.reject(fn item ->
        cond do
          item |> String.contains?("AAA") -> true
          String.length(item) - String.length(item |> String.replace("L", "")) > 1 -> true
          true -> false
        end
      end)
end

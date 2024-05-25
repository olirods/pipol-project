defmodule Pipol.Social do
  def analysis(person) do
    HTTPoison.get!("http://social-analyzer:7000/people/#{person.name}/emotions", [], recv_timeout: 50_000)
    |> Map.get(:body, [])
    |> Jason.decode!()
    |> Map.drop(["others"])
    |> normalize()
    |> Enum.sort(:desc)
  end

  defp normalize(map) do
    total = Map.values(map) |> Enum.sum()
    Enum.map(map, fn {key, value} -> {key, value / total} end)
  end
end

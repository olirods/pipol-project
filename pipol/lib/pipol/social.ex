defmodule Pipol.Social do
  def analysis(person) do
    result = HTTPoison.get!("http://social-analyzer:7000/people/#{person.name}/emotions", [], recv_timeout: 50_000)
    |> Map.get(:body, [])
    |> Jason.decode()

    case result do
      {:ok, data} ->
        data
        |> Map.drop(["others"])
        |> normalize()
        |> Enum.sort(:desc)
      {:error, error} ->
        [{"joy", 0.76}, {"surprise", 0.24}]
    end

  end

  defp normalize(map) do
    total = Map.values(map) |> Enum.sum()
    Enum.map(map, fn {key, value} -> {key, value / total} end)
  end
end

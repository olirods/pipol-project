defmodule Pipol.Popularity do
  alias Pipol.Person

  def ranking do
    HTTPoison.get!("http://popularity-tracker:5000/people/ranking", [], recv_timeout: 50_000)
    |> Map.get(:body, [])
    |> Jason.decode!()
    |> Enum.map(fn %{"name" => name, "why" => why} ->
      %Person{id: :rand.uniform(1_000), name: name, popular: {true, why}}
    end)
  end

  def history(person) do
    result = HTTPoison.get!("http://popularity-tracker:5000/people/#{String.replace(person.name, " ", "%20")}/history", [], recv_timeout: 50_000)

    case result do
      %HTTPoison.Response{status_code: 200} -> parse_history(result)
      _ -> nil
    end
  end

  defp parse_history(result) do
    result
    |> Map.get(:body, [])
    |> Jason.decode!()
    |> Enum.map(fn {k, v} ->
      {
        DateTime.from_unix!(String.to_integer(k), :millisecond) |> DateTime.to_date,
        v
      }
    end)
    |> Enum.sort(fn {date1, _}, {date2, _} -> Date.compare(date1, date2) != :gt end)
  end
end

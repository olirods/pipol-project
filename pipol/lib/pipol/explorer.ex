defmodule Pipol.Explorer do
  def abstract(person) do
    person
    |> get_resource_name()
    |> get_abstract()
  end

  def images(person) do
    items = HTTPoison.get!(
      "https://www.googleapis.com/customsearch/v1",
      [],
      params: %{
        key: Application.fetch_env!(:explorer, :google_api_key),
        cx: "a6bdcf3680e30404c",
        q: person.name,
        searchType: "image",
        gl: "es",
        hl: "es",
        lr: "lang-es",
        cr: "countryES",
        num: "5",
      },
      recv_timeout: 50_000)
    |> Map.get(:body, [])
    |> Jason.decode!()
    |> Map.get("items")

    if is_list(items) && length(items) > 0 do
      Enum.map(items, &(&1["link"]))
    else
      []
    end
  end

  defp get_resource_name(person) do
   {:ok, result} = """
    PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
    PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
    PREFIX dbo: <http://dbpedia.org/ontology/>
    PREFIX esres: <http://es.dbpedia.org/resource/>

    SELECT ?resource WHERE {
      ?resource rdf:type dbo:Person ;
                rdfs:label ?label .
      FILTER (langMatches(lang(?label), "es"))
      FILTER contains(?label, "#{person.name}")
    }
    LIMIT 1
    """
    |> SPARQL.Client.select("http://es.dbpedia.org/sparql", result_format: :json, request_method: :get, protocol_version: "1.1")

    List.first(result.results)["resource"]
  end

  defp get_abstract(resource) do
    {:ok, result} = """
    PREFIX dbo: <http://dbpedia.org/ontology/>

    SELECT ?abstract WHERE {
    <#{resource}> dbo:abstract ?abstract .
    }
    LIMIT 1
    """
    |> SPARQL.Client.select("http://es.dbpedia.org/sparql", result_format: :json, request_method: :get, protocol_version: "1.1")

    List.first(result.results)["abstract"]
  end
end

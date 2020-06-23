defmodule URIParser do
  @doc """
  Extracts path, query params, numeric IDs and UUIDs from the given URI and return them as a map.
  ## Examples
      iex> URIParser.parse("https://example.com/resource/3776a9b5-5f69-4d9e-be5e-74e574df02d6?page[number]=5&page[size]=3")
      %{
        authority: "example.com",
        fragment: nil,
        host: "example.com",
        ids: [],
        path: "/resource/:uuid",
        port: 443,
        query: %{"page[number]" => "5", "page[size]" => "3"},
        scheme: "https",
        userinfo: nil,
        uuids: ["3776a9b5-5f69-4d9e-be5e-74e574df02d6"]
      }

      iex> URIParser.parse("https://example.com/resource/3776a9b5-5f69-4d9e-be5e-74e574df02d6/some_action/03e9cc08-3739-452b-8c4b-a9d4cfc55549?sort=some_field")
      %{
        authority: "example.com",
        fragment: nil,
        host: "example.com",
        ids: [],
        path: "/resource/:uuid/some_action/:uuid",
        port: 443,
        query: %{"sort" => "some_field"},
        scheme: "https",
        userinfo: nil,
        uuids: ["3776a9b5-5f69-4d9e-be5e-74e574df02d6",
         "03e9cc08-3739-452b-8c4b-a9d4cfc55549"]
      }

      iex> URIParser.parse("https://example.com/resource?sort=some_field")
      %{
        authority: "example.com",
        fragment: nil,
        host: "example.com",
        ids: [],
        path: "/resource",
        port: 443,
        query: %{"sort" => "some_field"},
        scheme: "https",
        userinfo: nil,
        uuids: []
      }

      iex> URIParser.parse("https://example.com/resource?sort=some_field&sort=some_other_field&sort=yet_another_value&cool_param=true")
      %{
        authority: "example.com",
        fragment: nil,
        host: "example.com",
        ids: [],
        path: "/resource",
        port: 443,
        query: %{
          "cool_param" => "true",
          "sort" => ["some_field", "some_other_field", "yet_another_value"]
        },
        scheme: "https",
        userinfo: nil,
        uuids: []
      }

      iex> URIParser.parse("https://example.com/resource")
      %{
        authority: "example.com",
        fragment: nil,
        host: "example.com",
        ids: [],
        path: "/resource",
        port: 443,
        query: %{},
        scheme: "https",
        userinfo: nil,
        uuids: []
      }
  """

  @uuid_regex ~r/([a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12})+/
  @id_regex ~r/(?<=\/)\d+/

  def parse(uri) do
    uri
    |> URI.parse()
    |> Map.drop([:__struct__])
    |> parse_query()
    |> parse_uuids()
    |> parse_ids()
  end

  defp parse_uuids(data), do: parse_identifier(data, @uuid_regex, "uuid")

  defp parse_ids(data), do: parse_identifier(data, @id_regex, "id")

  defp parse_identifier(%{path: path} = data, regex, token) do
    identifiers =
      regex
      |> Regex.scan(path, capture: :first)
      |> List.flatten()

    new_path = Regex.replace(regex, path, ":" <> token)

    data
    |> Map.put(:"#{token}s", identifiers)
    |> Map.put(:path, new_path)
  end

  defp parse_query(%{query: query} = data) do
    query = query || ""

    decoded_query =
      query
      |> URI.query_decoder()
      |> Enum.reduce(%{}, fn({key, value}, acc) ->
        if Map.has_key?(acc, key) do
          add_to_query(acc, key, value)
        else
          Map.put(acc, key, value)
        end
      end)

    Map.put(data, :query, decoded_query)
  end

  defp add_to_query(query_map, key, value) do
    current_value = query_map[key]

    if is_list(current_value) do
      Map.put(query_map, key, current_value ++ [value])
    else
      Map.put(query_map, key, [current_value, value])
    end
  end
end

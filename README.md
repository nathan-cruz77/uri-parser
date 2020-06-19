# uri-parser
Extracts path, query params, numeric IDs and UUIDs from the given URIs.

## Usage
```elixir
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
```

defmodule URIParserTest do
  use ExUnit.Case, async: true

  describe "UUID" do
    test "single entry" do
      url = "https://example.com/resource/3776a9b5-5f69-4d9e-be5e-74e574df02d6"
      parsed = URIParser.parse(url)

      assert(parsed.path == "/resource/:uuid")
      assert(parsed.uuids == ["3776a9b5-5f69-4d9e-be5e-74e574df02d6"])
    end

    test "multiple entries" do
      url = "https://example.com/resource/3776a9b5-5f69-4d9e-be5e-74e574df02d6/some_action/03e9cc08-3739-452b-8c4b-a9d4cfc55549"
      parsed = URIParser.parse(url)

      assert(parsed.path == "/resource/:uuid/some_action/:uuid")
      assert(parsed.uuids == ["3776a9b5-5f69-4d9e-be5e-74e574df02d6", "03e9cc08-3739-452b-8c4b-a9d4cfc55549"])
    end

    test "no entry" do
      url = "https://example.com/resource"
      parsed = URIParser.parse(url)

      assert(parsed.path == "/resource")
      assert(parsed.uuids == [])
    end
  end

  describe "ID" do
    test "single entry" do
      url = "https://example.com/resource/9126885445002624981"
      parsed = URIParser.parse(url)

      assert(parsed.path == "/resource/:id")
      assert(parsed.ids == ["9126885445002624981"])
    end

    test "multiple entries" do
      url = "https://example.com/resource/7467384462010192719/some_action/2564"
      parsed = URIParser.parse(url)

      assert(parsed.path == "/resource/:id/some_action/:id")
      assert(parsed.ids == ["7467384462010192719", "2564"])
    end

    test "no entry" do
      url = "https://example.com/resource"
      parsed = URIParser.parse(url)

      assert(parsed.path == "/resource")
      assert(parsed.ids == [])
    end
  end

  describe "Query Params" do
    test "single entry" do
      url = "https://example.com/resource?sort=some_field"
      parsed = URIParser.parse(url)

      assert(parsed.path == "/resource")
      assert(parsed.query == %{"sort" => "some_field"})
    end

    test "multiple entries" do
      url = "https://example.com/resource?page[number]=5&page[size]=3"
      parsed = URIParser.parse(url)

      assert(parsed.path == "/resource")
      assert(parsed.query == %{"page[number]" => "5", "page[size]" => "3"})
    end

    test "two entries for same key" do
      url = "https://example.com/resource?sort=some_field&sort=some_other_field"
      parsed = URIParser.parse(url)

      assert(parsed.path == "/resource")
      assert(parsed.query == %{"sort" => ["some_field", "some_other_field"]})
    end

    test "multiple entries for same key" do
      url = "https://example.com/resource?sort=some_field&sort=some_other_field&sort=yet_another_value"
      parsed = URIParser.parse(url)

      assert(parsed.path == "/resource")
      assert(parsed.query == %{"sort" => ["some_field", "some_other_field", "yet_another_value"]})
    end

    test "no entry" do
      url = "https://example.com/resource"
      parsed = URIParser.parse(url)

      assert(parsed.path == "/resource")
      assert(parsed.query == %{})
    end
  end

  test "All together" do
    url =
      "https://example.com/resource" <>
      "/3776a9b5-5f69-4d9e-be5e-74e574df02d6" <>
      "/some_action/12/another_action/6866833322509886365" <>
      "/03e9cc08-3739-452b-8c4b-a9d4cfc55549" <>
      "?sort=some_field&list_param=a&list_param=b&other_list=55&other_list=26&other_list=58"

    parsed = URIParser.parse(url)

    assert(parsed.path == "/resource/:uuid/some_action/:id/another_action/:id/:uuid")
    assert(parsed.uuids == ["3776a9b5-5f69-4d9e-be5e-74e574df02d6", "03e9cc08-3739-452b-8c4b-a9d4cfc55549"])
    assert(parsed.ids == ["12", "6866833322509886365"])

    assert(parsed.query == %{
      "sort" => "some_field",
      "list_param" => ["a", "b"],
      "other_list" => ["55", "26", "58"]
    })
  end
end

defmodule UtilTest do
  use ExUnit.Case, async: true

  test "parses opts" do
    expected = %{
      "foo" => 13,
      "bar" => "bar"
    }

    assert Util.parse_opts(foo: 13) === expected
  end

  test "parses opts #2" do
    expected = %{
      "foo" => 42,
      "bar" => []
    }

    assert Util.parse_opts(bar: []) === expected
  end

  test "parses opts #3" do
    expected = %{
      "foo" => :goo,
      "bar" => {}
    }

    assert Util.parse_opts(foo: :goo, bar: {}) === expected
  end
end

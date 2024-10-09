defmodule Util do
  def parse_opts(opts) do
    %{
      "foo" => get_or_default(opts, :foo, 42),
      "bar" => get_or_default(opts, :bar, "bar")
    }
  end

  defp get_or_default(opts, key, default) do
    case Keyword.fetch(opts, key) do
      {:ok, val} -> val
      :error -> default
    end
  end
end

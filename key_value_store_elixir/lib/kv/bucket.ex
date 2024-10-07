defmodule KV.Bucket do
  def start_link(_opts) do
    Agent.start_link(fn -> %{} end)
  end

  def get(bucket, key) do
    Agent.get(bucket, fn state -> Map.get(state, key) end)
  end

  def put(bucket, key, value) do
    Agent.update(bucket, fn state -> Map.put(state, key, value) end)
  end

  def delete(bucket, key) do
    Agent.get_and_update(bucket, fn state ->
      value = Map.get(state, key)
      {value, Map.delete(state, key)}
    end)
  end
end

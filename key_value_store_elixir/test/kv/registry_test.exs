defmodule KV.RegistryTest do
  use ExUnit.Case, async: true

  @shopping_bucket_name "shopping"

  setup do
    # start_supervised! will ensure that KV.Registry is shutdown
    # between each tests
    #
    # Helps if your code depends on global resource
    #
    # Notice: KV.Registry uses DynamicSupervisor named :"KV.BucketSupervisor"
    # It is started because tests are running with started application
    # And our application starts global :"KV.BucketSupervisor" and :"KV.Registry" (altough tests dont rely on this one)
    registry = start_supervised!(KV.Registry)
    %{registry: registry}
  end

  test "spawns buckets", %{registry: registry} do
    assert KV.Registry.lookup(registry, @shopping_bucket_name) == :error

    KV.Registry.create(registry, @shopping_bucket_name)
    assert {:ok, bucket} = KV.Registry.lookup(registry, @shopping_bucket_name)

    KV.Bucket.put(bucket, "milk", 1)
    assert KV.Bucket.get(bucket, "milk") == 1
  end

  test "removes buckets on exit", %{registry: registry} do
    KV.Registry.create(registry, @shopping_bucket_name)
    {:ok, bucket} = KV.Registry.lookup(registry, @shopping_bucket_name)
    Agent.stop(bucket)
    assert KV.Registry.lookup(registry, @shopping_bucket_name) == :error
  end

  test "removes buckets on explicit crash", %{registry: registry} do
    KV.Registry.create(registry, @shopping_bucket_name)
    {:ok, bucket} = KV.Registry.lookup(registry, @shopping_bucket_name)

    # Remove bucket with not-normal reason
    # Basically simulate crash
    Agent.stop(bucket, :shutdown)
    assert KV.Registry.lookup(registry, @shopping_bucket_name)
  end
end

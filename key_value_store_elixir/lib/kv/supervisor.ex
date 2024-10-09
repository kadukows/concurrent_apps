defmodule KV.Supervisor do
  use Supervisor

  # I guess client?
  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  # I guess callbacks?
  @impl true
  def init(:ok) do
    children = [
      # It is important that KV.BucketSupervisor is started before KV.Registry
      # As KV.Registry uses KV.BucketSupervisor
      {DynamicSupervisor, name: KV.BucketSupervisor, strategy: :one_for_one},
      {KV.Registry, name: KV.Registry}
    ]

    # It is important that this is :one_for_all
    # If KV.Registry dies, we want KV.BucketSupervisor to also be restarted (as to not cause resource leakage)
    Supervisor.init(children, strategy: :one_for_all)
  end

end

defmodule KV.Registry do
  use GenServer

  ## Client API

  @doc """
  Starts the registry
  """
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @doc """
  Looks up the bucket pid for 'name' stored in 'server'

  Returns '{:ok, pid}' if the bucket exists, ':error' otherwise
  """
  def lookup(server, name) do
    GenServer.call(server, {:lookup, name})
  end

  @doc """
  Ensures there is a bucket associated with the given 'name' in 'server'
  """
  def create(server, name) do
    GenServer.call(server, {:create, name})
  end


  ## GenServer callbacks

  @impl true
  def init(:ok) do
    names_to_pids = %{}
    refs_to_names = %{}
    {:ok, {names_to_pids, refs_to_names}}
  end

  @impl true
  def handle_call({:lookup, name}, _from, {names, refs}) do
    {:reply, Map.fetch(names, name), {names, refs}}
  end

  # handle_cast/2 Does not guarantee that server received message
  # Used only for didactic purposes
  # def handle_cast({:create, name}, {names, refs}) do

  @impl true
  def handle_call({:create, name}, _from, {names, refs}) do
    if Map.has_key?(names, name) do
      {:reply, :ok, {names, refs}}
    else
      {:ok, pid} = DynamicSupervisor.start_child(KV.BucketSupervisor, KV.Bucket)
      ref = Process.monitor(pid)
      refs = Map.put(refs, ref, name)
      names = Map.put(names, name, pid)

      {:reply, :ok, {names, refs}}
    end
  end

  @impl true
  def handle_info({:DOWN, ref, :process, _pid, _reason}, {names, refs}) do
    {name, refs} = Map.pop(refs, ref)
    names = Map.delete(names, name)
    {:noreply, {names, refs}}
  end

  @impl true
  def handle_info(msg, state) do
    require Logger
    Logger.debug("Unexpected message in KV.Registry: #{inspect(msg)}")
    {:noreply, state}
  end
end

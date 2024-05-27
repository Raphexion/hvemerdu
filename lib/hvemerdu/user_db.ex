defmodule Hvemerdu.UserDB do
  @moduledoc """
  An in-memory database
  """
  use GenServer

  @default_db %{
    "nijo" => "1234"
  }

  def fetch(server \\ __MODULE__, user) do
    GenServer.call(server, {:fetch, user})
  end

  def put(server \\ __MODULE__, user, pass) do
    GenServer.call(server, {:put, user, pass})
  end

  def start_link(opts \\ %{}, gopts \\ [name: __MODULE__]) do
    GenServer.start_link(__MODULE__, opts, gopts)
  end

  @impl true
  def init(_) do
    {:ok, @default_db}
  end

  @impl true
  def handle_call({:fetch, user}, _from, db) do
    result =
      case Map.fetch(db, user) do
        {:ok, pass} -> {:ok, pass}
        :error -> {:error, :missing}
      end

    {:reply, result, db}
  end

  def handle_call({:put, user, pass}, _from, db) do
    db = Map.put(db, user, pass)
    {:reply, :ok, db}
  end
end

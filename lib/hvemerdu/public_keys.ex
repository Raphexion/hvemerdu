defmodule Hvemerdu.PublicKeys do
  @moduledoc """
  Reads up the public keys at start-up
  """
  use GenServer

  alias Hvemerdu.Keys

  require Logger

  def start_link(opts \\ :ok, gopts \\ [name: __MODULE__]) do
    GenServer.start_link(__MODULE__, opts, gopts)
  end

  def put(server \\ __MODULE__, public_key) do
    GenServer.call(server, {:put, public_key})
  end

  def verify_jwt(jwt) do
    public_keys = :persistent_term.get({__MODULE__, :public_keys})
    verify_jwt_with_public_keys(jwt, public_keys)
  end

  @impl true
  def init(_) do
    {:ok, :no_state, {:continue, :load}}
  end

  @impl true
  def handle_continue(:load, :no_state) do
    original = load_public_keys()
    :persistent_term.put({__MODULE__, :public_keys}, original)
    {:noreply, original}
  end

  @impl true
  def handle_call({:put, public_key}, _from, public_keys) do
    updated = [public_key | public_keys]
    :persistent_term.put({__MODULE__, :public_keys}, updated)
    {:reply, :ok, updated}
  end

  defp load_public_keys() do
    priv_dir = :code.priv_dir(:hvemerdu)
    public_keys_folder = Path.join([priv_dir, "public_keys"])

    public_key_files =
      case File.ls(public_keys_folder) do
        {:ok, files} ->
          files

        {:error, _} ->
          Logger.warning("unable to list public_keys_folder=#{public_keys_folder}")
          []
      end

    Enum.map(public_key_files, fn file ->
      file_path = Path.join(public_keys_folder, file)
      Keys.read_from_pem(file_path)
    end)
  end

  defp verify_jwt_with_public_keys(jwt, public_keys) do
    public_keys
    |> Enum.find_value(fn public_key ->
      case Keys.verify(jwt, public_key) do
        {:ok, claims} -> {:ok, claims}
        {:error, _} -> nil
      end
    end)
    |> case do
      {:ok, claims} -> {:ok, claims}
      nil -> {:error, :deny}
    end
  end
end

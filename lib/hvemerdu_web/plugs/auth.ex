defmodule HvemerduWeb.Plugs.Auth do
  @moduledoc false

  # Plug.BasicAuth
  import Plug.Conn

  alias Hvemerdu.UserDB
  alias Plug.BasicAuth

  def init(opts), do: opts

  def call(conn, _opts) do
    with {user, pass} <- Plug.BasicAuth.parse_basic_auth(conn),
         {:ok, ^user} <- find_by_username_and_password(user, pass) do
      assign(conn, :current_user, user)
    else
      _ ->
        conn
        |> BasicAuth.request_basic_auth()
        |> halt()
    end
  end

  defp find_by_username_and_password(user, pass) do
    user = String.trim(user)
    pass = String.trim(pass)

    case UserDB.fetch(user) do
      {:ok, ^pass} -> {:ok, user}
      {:ok, _} -> {:error, :bad_pass}
      :error -> {:error, :bad_user}
    end
  end
end

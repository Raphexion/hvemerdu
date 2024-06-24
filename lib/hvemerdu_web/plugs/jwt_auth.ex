defmodule HvemerduWeb.Plugs.JwtAuth do
  @moduledoc false

  import Plug.Conn

  alias Hvemerdu.PublicKeys

  @error Jason.encode!(%{error: "Unauthorized"})

  def init(opts), do: opts

  def call(conn, _opts) do
    with ["Bearer " <> encoded_jwt] <- get_req_header(conn, "authorization"),
         {:ok, jwt} <- Base.decode64(encoded_jwt) do
      verify_jwt(conn, jwt)
    else
      _ ->
        unauthorized_response(conn)
    end
  end

  defp verify_jwt(conn, jwt) do
    now = :os.system_time(:seconds)

    case PublicKeys.verify_jwt(jwt) do
      {:ok, %{"exp" => exp} = claims} when exp > now ->
        conn
        |> assign(:jwt_claims, claims)

      {:ok, _} ->
        unauthorized_response(conn)

      {:error, _} ->
        unauthorized_response(conn)
    end
  end

  defp unauthorized_response(conn) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(:unauthorized, @error)
    |> halt()
  end
end

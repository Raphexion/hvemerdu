defmodule HvemerduWeb.UnsafeAckController do
  use HvemerduWeb, :controller

  alias Hvemerdu.InterCom

  def ack(conn, %{"code" => code}) do
    symbols =
      code
      |> String.upcase()
      |> String.graphemes()

    InterCom.broadcast_verified(symbols)
    json(conn, %{"status" => "success"})
  end

  def ack(conn, _params) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{"error" => "code missing in payload"})
  end
end

defmodule HvemerduWeb.UnsafeAckControllerTest do
  use HvemerduWeb.ConnCase

  alias Hvemerdu.InterCom
  alias Phoenix.Socket.Broadcast

  test "it is possibe to put an ack with code", %{conn: conn} do
    assert :ok = InterCom.subscribe()

    payload = %{code: "1a2b3C", name: "Lisa"}
    conn = post(conn, ~p"/v1/unsafe-acks", payload)
    assert json_response(conn, 200)

    expected = %{personal_code: ["1", "A", "2", "B", "3", "C"]}
    assert_receive %Broadcast{payload: ^expected}
  end

  test "it returns and error if code is missing", %{conn: conn} do
    payload = %{}
    conn = post(conn, ~p"/v1/unsafe-acks", payload)
    assert json_response(conn, 422)
  end
end

defmodule HvemerduWeb.VerifyControllerTest do
  use HvemerduWeb.ConnCase

  @tag :with_valid_jwt
  test "it is possibe to verify a code with a valid jwt", %{conn: conn} do
    body = %{"code" => "123456"}
    conn = post(conn, ~p"/v1/verify", body)
    assert %{"status" => "success"} = json_response(conn, 200)
  end

  @tag :with_invalid_jwt
  test "it is not possibe to verify a code with a invalid jwt", %{conn: conn} do
    body = %{"code" => "123456"}
    conn = post(conn, ~p"/v1/verify", body)
    assert %{"error" => "Unauthorized"} = json_response(conn, 401)
  end

  @tag :with_corrupt_jwt
  test "it is not possibe to verify a code with a corrupt jwt", %{conn: conn} do
    body = %{"code" => "123456"}
    conn = post(conn, ~p"/v1/verify", body)
    assert %{"error" => "Unauthorized"} = json_response(conn, 401)
  end

  @tag :with_outdated_jwt
  test "it is not possibe to verify a code with a outdated jwt", %{conn: conn} do
    body = %{"code" => "123456"}
    conn = post(conn, ~p"/v1/verify", body)
    assert %{"error" => "Unauthorized"} = json_response(conn, 401)
  end

  test "it is not possibe to verify a code without a jwt", %{conn: conn} do
    body = %{"code" => "123456"}
    conn = post(conn, ~p"/v1/verify", body)
    assert %{"error" => "Unauthorized"} = json_response(conn, 401)
  end
end

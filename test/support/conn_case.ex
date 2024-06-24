defmodule HvemerduWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use HvemerduWeb.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # The default endpoint for testing
      @endpoint HvemerduWeb.Endpoint

      use HvemerduWeb, :verified_routes

      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import HvemerduWeb.ConnCase
    end
  end

  setup [
    :setup_conn,
    :setup_keys,
    :setup_auth
  ]

  def setup_conn(_context) do
    conn =
      Phoenix.ConnTest.build_conn()
      |> Plug.Conn.put_req_header("content-type", "application/json")

    [conn: conn]
  end

  def setup_keys(_context) do
    {:ok, private, public} = Hvemerdu.Keys.generate_pair()
    :ok = Hvemerdu.PublicKeys.put(public)

    %{private: private}
  end

  def setup_auth(%{conn: conn, with_valid_jwt: true, private: private}) do
    now = :os.system_time(:seconds)

    claims = %{
      "exp" => now + 60,
      "nbf" => now,
      "iat" => now
    }

    jwt = Hvemerdu.Keys.sign(private, claims)
    [conn: put_bearer(conn, Base.encode64(jwt))]
  end

  def setup_auth(%{conn: conn, with_invalid_jwt: true}) do
    {:ok, private, _} = Hvemerdu.Keys.generate_pair()

    now = :os.system_time(:seconds)

    claims = %{
      "exp" => now + 60,
      "nbf" => now,
      "iat" => now
    }

    jwt = Hvemerdu.Keys.sign(private, claims)
    [conn: put_bearer(conn, Base.encode64(jwt))]
  end

  def setup_auth(%{conn: conn, with_outdated_jwt: true, private: private}) do
    before = :os.system_time(:seconds) - 3600

    claims = %{
      "exp" => before + 60,
      "nbf" => before,
      "iat" => before
    }

    jwt = Hvemerdu.Keys.sign(private, claims)
    [conn: put_bearer(conn, Base.encode64(jwt))]
  end

  def setup_auth(%{conn: conn, with_corrupt_jwt: true}) do
    [conn: put_bearer(conn, "bad-jwt-data")]
  end

  def setup_auth(_context) do
    :ok
  end

  defp put_bearer(conn, value) do
    Plug.Conn.put_req_header(conn, "authorization", "Bearer " <> value)
  end
end

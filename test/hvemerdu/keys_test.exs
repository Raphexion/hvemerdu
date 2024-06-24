defmodule Hvemerdu.KeysTest do
  use ExUnit.Case, async: true

  alias Hvemerdu.Keys

  test "it is possible to sign and verify a jwt" do
    assert {:ok, private, public} = Keys.generate_pair()

    claims = %{"sub" => "1234567890", "name" => "John Doe", "admin" => true}
    jwt = Keys.sign(private, claims)

    assert {:ok, ^claims} = Joken.peek_claims(jwt)
    assert {:ok, ^claims} = Keys.verify(jwt, public)
  end

  test "it reject the signature if public key is different" do
    assert {:ok, private, _} = Keys.generate_pair()
    assert {:ok, _, public} = Keys.generate_pair()

    claims = %{"sub" => "1234567890", "name" => "John Doe", "admin" => true}
    jwt = Keys.sign(private, claims)

    assert {:ok, ^claims} = Joken.peek_claims(jwt)
    assert {:error, :signature_error} = Keys.verify(jwt, public)
  end
end

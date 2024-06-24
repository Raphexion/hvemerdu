defmodule Hvemerdu.Keys.Generate do
  @moduledoc """
  Module to generate a key pair
  """
  def generate_pair do
    # Use the P-256 curve (Elliptic Curve) with the HS256 algorithm (HMAC using SHA-256)
    private_key = JOSE.JWK.generate_key({:ec, "P-256"})
    public_key = JOSE.JWK.to_public(private_key)

    {:ok, private_key, public_key}
  end
end

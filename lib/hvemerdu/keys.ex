defmodule Hvemerdu.Keys do
  @moduledoc false

  alias Hvemerdu.Keys.Generate
  alias Hvemerdu.Keys.IO

  defdelegate generate_pair(), to: Generate
  defdelegate read_from_pem(filename), to: IO
  defdelegate save_to_pem(key, filename), to: IO

  def sign(private, claims \\ %{}) do
    # We should use ES256 for the Elliptic Curve key (P-256)
    jws = %{"typ" => "JWT", "alg" => "ES256"}
    jwt = JOSE.JWT.sign(private, jws, claims)

    {_, compact_jwt} = JOSE.JWS.compact(jwt)
    compact_jwt
  end

  def verify(jwt, %JOSE.JWK{} = public) do
    {_, key_map} = JOSE.JWK.to_map(public)
    signer = Joken.Signer.create("ES256", key_map)
    Joken.verify(jwt, signer)
  end
end

defmodule Hvemerdu.Keys.IO do
  @moduledoc """
  Input/Output of keys
  """

  def save_to_pem(key, filename) do
    {_, content} = JOSE.JWK.to_pem(key)
    :ok = File.write!(filename, content)
  end

  def read_from_pem(filename) do
    {:ok, content} = File.read(filename)
    JOSE.JWK.from_pem(content)
  end
end

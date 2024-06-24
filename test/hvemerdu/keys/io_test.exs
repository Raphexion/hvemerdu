defmodule Hvemerdu.Keys.IOTest do
  use ExUnit.Case, async: true

  alias Hvemerdu.Keys
  alias Hvemerdu.Keys.IO

  @tag :tmp_dir
  test "it is possible to write and read keys", %{tmp_dir: tmp_dir} do
    assert {:ok, private, public} = Keys.generate_pair()

    private_filename = Path.join([tmp_dir, "private.pem"])
    public_filename = Path.join([tmp_dir, "public.pem"])

    assert :ok = IO.save_to_pem(private, private_filename)
    assert :ok = IO.save_to_pem(public, public_filename)

    assert ^private = IO.read_from_pem(private_filename)
    assert ^public = IO.read_from_pem(public_filename)
  end
end

alias Hvemerdu.Keys

File.mkdir_p!(Path.join(["private_keys"]))
File.mkdir_p!(Path.join(["priv", "public_keys"]))

private_pem = Path.join(["private_keys", "script_generated.pem"])
public_pem = Path.join(["priv", "public_keys", "script_generated.pem"])

{:ok, private, public} = Keys.generate_pair()
:ok = Keys.save_to_pem(private, private_pem)
:ok = Keys.save_to_pem(public, public_pem)

alias Hvemerdu.Keys

{:ok, code, url} =
  System.argv()
  |> case do
    [code, "prod"] ->
      {:ok, code, "https://hvemerdu.dk/v1/verify"}

    [code, "dev"] ->
      {:ok, code, "http://localhost:4000/v1/verify"}

    [code] ->
      {:ok, code, "http://localhost:4000/v1/verify"}

    _ ->
      raise "please specify code"
  end

private_pem = Path.join(["private_keys", "script_generated.pem"])
private = Keys.read_from_pem(private_pem)

jti = for _ <- 1..12, into: "", do: <<Enum.random(~c"0123456789abcdef")>>

claims = %{
  "iss" => "Hvemerdu",
  "sub" => "Hvemerdu",
  "aud" => "Hvemerdu",
  # Expiration time (1 minute from now)
  "exp" => :os.system_time(:seconds) + 60,
  # Not before time
  "nbf" => :os.system_time(:seconds),
  # Issued at time
  "iat" => :os.system_time(:seconds),
  # JWT ID (unique identifier for the JWT)
  "jti" => jti
}

jwt = Keys.sign(private, claims)

headers = [
  {"Authorization", "Bearer " <> Base.encode64(jwt)},
  {"Content-Type", "application/json"}
]

body = %{
  "code" => code,
  "name" => "Anna Johansson",
  "avatar" => "https://exaple.com/1234"
}

Req.post(url,
  headers: headers,
  body: Jason.encode!(body)
)
|> case do
  {:ok, %Req.Response{status: 200}} ->
    IO.puts("successfully verified the code")

  {:ok, %Req.Response{status: status}} ->
    IO.puts("failed with status=#{status}")
end

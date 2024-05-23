defmodule Hvemerdu.InterCom do
  @moduledoc """
  Helps to send message inside our system
  """

  alias HvemerduWeb.Endpoint

  @topic "personal-codes"

  def subscribe do
    Endpoint.subscribe(@topic)
  end

  def broadcast_verified(personal_code) do
    payload = %{personal_code: personal_code}
    Endpoint.broadcast!(@topic, "code-entered", payload)
  end

  def broadcast_success(personal_code) do
    payload = %{personal_code: personal_code}
    Endpoint.broadcast!(@topic, "success", payload)
  end
end

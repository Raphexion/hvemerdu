defmodule HvemerduWeb.ChallengeLive do
  @moduledoc false
  use HvemerduWeb, :live_view

  @size 6

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(size: @size)
      |> assign(symbols: symbols())

    {:ok, socket}
  end

  defp symbols do
    1..@size
    |> Enum.map(fn ii ->
      if rem(ii, 3) == 0 do
        Enum.random(["A", "B", "C", "D", "E", "F", "G", "H"])
      else
        Enum.random(2..9)
      end
    end)
  end
end

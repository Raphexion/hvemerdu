defmodule HvemerduWeb.ChallengeLive do
  @moduledoc false
  use HvemerduWeb, :live_view

  alias Hvemerdu.InterCom
  alias Phoenix.Socket.Broadcast

  @size 6

  def size, do: @size

  def mount(_params, _session, socket) do
    connected? = connected?(socket)

    if connected? do
      InterCom.subscribe()
    end

    socket =
      socket
      |> assign(:verified?, false)
      |> assign(size: @size)
      |> assign(symbols: symbols(connected?))

    {:ok, socket}
  end

  def waiting(assigns) do
    ~H"""
    <div>
      <div style="display: flex; flex-direction: row; justify-content: space-around;">
        <div :for={symbol <- @symbols} class="text-3xl p-4 rounded-lg bg-orange-500 text-yellow-50">
          <%= symbol %>
        </div>
      </div>
      <div class="text-xl text-center p-4 text-yellow-950">
        Den person, du taler med i telefonen, skal bekræfte denne kode.
      </div>
      <div class="text-xl text-center p-4 text-yellow-950">
        Venter på bekræftelse ...
      </div>
      <div class="flex justify-center">
        <span class="relative flex h-10 w-10">
          <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-amber-400 opacity-75">
          </span>
          <span class="relative inline-flex rounded-full h-10 w-10 bg-amber-500"></span>
        </span>
      </div>
    </div>
    """
  end

  def success(assigns) do
    ~H"""
    <div class="text-3xl text-center p-4 text-yellow-950">
      OK!
    </div>
    """
  end

  def handle_info(%Broadcast{event: "success"}, socket) do
    {:noreply, socket}
  end

  def handle_info(%Broadcast{event: "code-entered", payload: %{personal_code: symbols}}, socket) do
    if symbols == socket.assigns.symbols do
      InterCom.broadcast_success(symbols)
      {:noreply, assign(socket, :verified?, true)}
    else
      {:noreply, socket}
    end
  end

  defp symbols(false) do
    for _ <- 1..@size, do: "*"
  end

  defp symbols(true) do
    1..@size
    |> Enum.map(fn ii ->
      if rem(ii, 3) == 0 do
        Enum.random(["C", "D", "E", "F", "G", "H", "K", "L", "M", "N", "P", "Q", "R", "T", "X"])
      else
        Enum.random(2..9) |> Integer.to_string()
      end
    end)
  end
end

defmodule HvemerduWeb.VerifyLive do
  @moduledoc false
  use HvemerduWeb, :live_view

  alias Hvemerdu.InterCom
  alias Phoenix.Socket.Broadcast

  @size 6
  @default List.duplicate("_", @size)

  defguardp is_letter(c) when c in ?a..?z or c in ?A..?Z
  defguardp is_digit(c) when c in ?0..?9

  def mount(_params, _session, socket) do
    if connected?(socket) do
      InterCom.subscribe()
    end

    socket =
      socket
      |> assign(:verified?, false)
      |> clear_to(0)

    {:ok, socket}
  end

  def waiting(assigns) do
    ~H"""
    <div>
      <div class="text-3xl text-center p-4 text-yellow-950">
        Indtast kundens kode
      </div>

      <div style="display: flex; flex-direction: row; justify-content: space-around;">
        <div :for={symbol <- @symbols} class="text-3xl p-4 rounded-lg bg-blue-500 text-yellow-100">
          <%= symbol %>
        </div>
      </div>
    </div>
    """
  end

  def success(assigns) do
    ~H"""
    <div class="text-3xl text-center p-4 text-yellow-950">
      Kundens kode er bekræftet!
    </div>
    """
  end

  def handle_info(%Broadcast{event: "code-entered"}, socket) do
    {:noreply, socket}
  end

  def handle_info(%Broadcast{event: "success", payload: %{personal_code: symbols}}, socket) do
    if symbols == socket.assigns.symbols do
      {:noreply, assign(socket, :verified?, true)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("key_down", _, socket) do
    {:noreply, socket}
  end

  @delete_keys ["Backspace", "Delete"]
  def handle_event("key_up", %{"key" => key}, socket) when key in @delete_keys do
    at = socket.assigns.at
    {:noreply, clear_to(socket, at - 1)}
  end

  def handle_event("key_up", %{"key" => <<c::8, _::binary>>}, socket)
      when is_letter(c) or is_digit(c) do
    at = socket.assigns.at
    symbol = String.upcase(<<c::8>>)
    {:noreply, add_at(socket, at, symbol) |> maybe_publish()}
  end

  def handle_event("key_up", %{"key" => _}, socket) do
    {:noreply, socket}
  end

  defp clear_to(socket, at) when at <= 0 do
    socket
    |> assign(at: 0)
    |> assign(symbols: @default)
  end

  defp clear_to(socket, at) when at >= @size do
    socket
  end

  defp clear_to(socket, at) do
    symbols = socket.assigns.symbols
    {left, _right} = Enum.split(symbols, at)

    symbols = (left ++ @default) |> Enum.take(@size)

    socket
    |> assign(at: at)
    |> assign(symbols: symbols)
  end

  defp add_at(socket, at, _symbol) when at >= @size do
    socket
  end

  defp add_at(socket, at, symbol) when at >= 0 do
    symbols = socket.assigns.symbols
    {left, _right} = Enum.split(symbols, at)

    symbols = (left ++ [symbol] ++ @default) |> Enum.take(@size)

    socket
    |> assign(at: at + 1)
    |> assign(symbols: symbols)
  end

  defp maybe_publish(%{assigns: %{at: @size, symbols: symbols}} = socket) do
    InterCom.broadcast_verified(symbols)
    socket
  end

  defp maybe_publish(socket) do
    socket
  end
end

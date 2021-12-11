# TODO stopped here https://youtu.be/fyg0FuSL5DY?t=1984

defmodule ChatWeb.RoomLive do
  use ChatWeb, :live_view
  require Logger

  @impl true
  def mount(%{"id" => room_id }, _session, socket) do
    Logger.info(">> mounted room >> " <> room_id)
    {:ok, assign(socket, room_id: room_id)}
  end
end

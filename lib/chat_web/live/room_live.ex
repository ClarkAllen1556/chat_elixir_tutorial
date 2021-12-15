# TODO stopped here https://youtu.be/fyg0FuSL5DY?t=3135

defmodule ChatWeb.RoomLive do
  use ChatWeb, :live_view
  require Logger

  @impl true
  def mount(%{"id" => room_id}, _session, socket) do
    Logger.info(">> mounted room >> " <> room_id)

    username = MnemonicSlugs.generate_slug(2)

    topic = "room:" <> room_id
    # put in @ 59:00min
    if connected?(socket), do: ChatWeb.Endpoint.subscribe(topic)

    {:ok,
     assign(socket,
       room_id: room_id,
       username: username,
       topic: topic,
       message: "",
       messages: [
         %{
           uuid: UUID.uuid4(),
           content: "#{username} joined!",
           username: "system"
         }
       ]
     ), temporary_assigns: [messages: []]}
  end

  @impl true
  def handle_event("submit_message", %{"chat" => %{"message" => message}}, socket) do
    message = %{uuid: UUID.uuid4(), content: message, username: socket.assigns.username}

    Logger.info(sent: message)

    ChatWeb.Endpoint.broadcast(socket.assigns.topic, "new-message", message)

    {:noreply, assign(socket, message: "")}
  end

  @impl true
  def handle_event("form_updated", %{"chat" => %{"message" => message}}, socket) do
    Logger.info(message: message)

    {:noreply, assign(socket, message: message)}
  end

  @impl true
  def handle_info(%{event: "new-message", payload: message}, socket) do
    Logger.info(received: message)

    {:noreply, assign(socket, messages: [message])}
  end
end

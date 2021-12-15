# TODO stopped here https://youtu.be/fyg0FuSL5DY?t=4728

defmodule ChatWeb.RoomLive do
  use ChatWeb, :live_view
  require Logger

  @impl true
  def mount(%{"id" => room_id}, _session, socket) do
    Logger.info(">> mounted room >> " <> room_id)

    username = MnemonicSlugs.generate_slug(2)

    topic = "room:" <> room_id
    # put in @ 59:00min
    if connected?(socket) do
      ChatWeb.Endpoint.subscribe(topic)
      ChatWeb.Presence.track(self(), topic, username, %{})
    end

    {:ok,
     assign(socket,
       room_id: room_id,
       username: username,
       topic: topic,
       message: "",
       messages: []
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

  @impl true
  def handle_info(%{event: "presence_diff", payload: %{joins: joins, leaves: leaves}}, socket) do
    Logger.info(joins: joins, leaves: leaves)

    join_messages =
      joins
      |> Map.keys()
      |> Enum.map(fn username ->
        %{uuid: UUID.uuid4(), content: "#{username} joined!", username: "system"}
      end)

    leave_messages =
      leaves
      |> Map.keys()
      |> Enum.map(fn username ->
        %{uuid: UUID.uuid4(), content: "#{username} left.", username: "system"}
      end)

    Logger.info(join_messages: join_messages, leave_messages: leave_messages)

    {:noreply, assign(socket, messages: join_messages ++ leave_messages)}
  end
end

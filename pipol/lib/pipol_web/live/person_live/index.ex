defmodule PipolWeb.PersonLive.Index do
  use PipolWeb, :live_view

  alias Pipol.Popularity

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign_async(socket, :people, fn -> {:ok, %{people: Popularity.ranking()}} end)}
  end

  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("click-person", %{"id" => id}, socket) do
    person = Enum.find(socket.assigns.people.result, &(&1.id == id))

    {:noreply,
     socket
     |> assign(person: person)
     |> push_patch(to: "/#{person.name}")}
  end
end

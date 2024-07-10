defmodule PipolWeb.PersonLive.Index do
  use PipolWeb, :live_view

  alias Pipol.Popularity
  alias Pipol.Person

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :show_input, false)}
  end

  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true
  def handle_event("click-person", %{"id" => id}, socket) do
    person = Enum.find(socket.assigns.people.result, &(&1.id == id))

    {:noreply,
     socket
     |> assign(person: person)
     |> push_patch(to: "/#{person.name}")}
  end

  @impl true
  def handle_event("toggle-input", _params, socket) do

    {:noreply, assign(socket, show_input: !socket.assigns.show_input)}
  end

  def handle_event("submit-form", %{"name" => name}, socket) do
    person = %Person{id: :rand.uniform(1_000), name: name, popular: {false, nil}}

    {:noreply,
    socket
    |> assign(person: person)
    |> push_patch(to: "/#{person.name}")}
  end

  defp apply_action(socket, :show, %{"person" => name}) do
    assign_new(socket, :person, fn -> %Person{id: :rand.uniform(1_000), name: name, popular: {false, nil}} end)
  end

  defp apply_action(socket, :index, _params) do
    socket =
      if(Map.get(socket.assigns, :people, %{result: nil}).result == nil) do
        socket
        |> assign_async(:people, fn -> {:ok, %{people: Popularity.ranking()}} end)
      else
        socket
      end

    socket
    |> assign(:show_input, false)
  end
end

defmodule PipolWeb.PersonLive.PersonComponent do
  @moduledoc false

  use PipolWeb, :live_component
  alias Pipol.Explorer
  alias Pipol.Popularity
  alias Pipol.Social

  @impl Phoenix.LiveComponent
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign_async(:social, fn -> {:ok, %{social: Social.analysis(assigns.person)}} end)
     |> assign_async(:history, fn -> {:ok, %{history: Popularity.history(assigns.person)}} end)
     |> assign_async(:images, fn -> {:ok, %{images: Explorer.images(assigns.person)}} end)
     |> assign_async(:abstract, fn -> {:ok, %{abstract: Explorer.abstract(assigns.person)}} end)
     |> assign(assigns)}
  end

  def handle_event("back", _params, socket) do
    {:noreply,
     socket
     |> push_patch(to: "/")}
  end

  defp emotion_emoji("anger"), do: "😠"
  defp emotion_emoji("disgust"), do: "🤢"
  defp emotion_emoji("fear"), do: "😠"
  defp emotion_emoji("joy"), do: "😊"
  defp emotion_emoji("sadness"), do: "😢"
  defp emotion_emoji("surprise"), do: "😮"
  defp emotion_emoji(_), do: "😐"
end

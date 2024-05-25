defmodule Pipol.PopularityFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Pipol.Popularity` context.
  """

  @doc """
  Generate a person.
  """
  def person_fixture(attrs \\ %{}) do
    {:ok, person} =
      attrs
      |> Enum.into(%{})
      |> Pipol.Popularity.create_person()

    person
  end
end

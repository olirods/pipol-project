defmodule Pipol.PopularityTest do
  use Pipol.DataCase

  alias Pipol.Popularity

  describe "people" do
    alias Pipol.Popularity.Person

    import Pipol.PopularityFixtures

    @invalid_attrs %{}

    test "list_people/0 returns all people" do
      person = person_fixture()
      assert Popularity.list_people() == [person]
    end

    test "get_person!/1 returns the person with given id" do
      person = person_fixture()
      assert Popularity.get_person!(person.id) == person
    end

    test "create_person/1 with valid data creates a person" do
      valid_attrs = %{}

      assert {:ok, %Person{} = person} = Popularity.create_person(valid_attrs)
    end

    test "create_person/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Popularity.create_person(@invalid_attrs)
    end

    test "update_person/2 with valid data updates the person" do
      person = person_fixture()
      update_attrs = %{}

      assert {:ok, %Person{} = person} = Popularity.update_person(person, update_attrs)
    end

    test "update_person/2 with invalid data returns error changeset" do
      person = person_fixture()
      assert {:error, %Ecto.Changeset{}} = Popularity.update_person(person, @invalid_attrs)
      assert person == Popularity.get_person!(person.id)
    end

    test "delete_person/1 deletes the person" do
      person = person_fixture()
      assert {:ok, %Person{}} = Popularity.delete_person(person)
      assert_raise Ecto.NoResultsError, fn -> Popularity.get_person!(person.id) end
    end

    test "change_person/1 returns a person changeset" do
      person = person_fixture()
      assert %Ecto.Changeset{} = Popularity.change_person(person)
    end
  end
end

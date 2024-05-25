defmodule Pipol.Repo.Migrations.CreatePeople do
  use Ecto.Migration

  def change do
    create table(:people) do

      timestamps(type: :utc_datetime)
    end
  end
end

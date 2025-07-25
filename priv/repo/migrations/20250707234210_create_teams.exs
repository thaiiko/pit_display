defmodule PitDisplay.Repo.Migrations.CreateTeams do
  use Ecto.Migration

  def change do
    create table(:teams, primary_key: false) do
      add :team_id, :integer, primary_key: true
      add :name, :string
      add :city, :string
      add :state_prov, :string
      add :country, :string
    end
  end
end

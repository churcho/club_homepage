defmodule ClubHomepage.Repo.Migrations.CreateMatch do
  use Ecto.Migration

  def change do
    create table(:matches) do
      add :start_at, :datetime
      add :home_match, :boolean, default: false
      add :season_id, references(:seasons)
      add :team_id, references(:teams)
      add :opponent_team_id, references(:opponent_teams)
      add :meeting_point_id, references(:meeting_points)

      timestamps
    end
    create index(:matches, [:season_id])
    create index(:matches, [:team_id])
    create index(:matches, [:opponent_team_id])
    create index(:matches, [:meeting_point_id])

  end
end

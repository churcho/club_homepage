# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     ClubHomepage.Repo.insert!(%SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias ClubHomepage.Repo

alias ClubHomepage.Address
alias ClubHomepage.Match
alias ClubHomepage.MeetingPoint
alias ClubHomepage.OpponentTeam
alias ClubHomepage.Team
alias ClubHomepage.Season
alias ClubHomepage.User

# First user is an administrator.
unless Repo.get_by(User, login: "administrator") do
  #{:ok, date} = Ecto.Date.cast("1970-01-01")
  date = Timex.Date.from({1970, 1, 1})
  changeset = User.registration_changeset(%User{}, %{
    active: true, 
    login: "administrator", password: "admin_password",  
    name: "Ad Min", email: "admin@example.com", 
    birthday: date, roles: "member administrator"
  })
  Repo.insert(changeset)
end

# Address
address_1 = %{zip_code: "08671", street: "My Club Street 1", city: "My Club City"}
unless Repo.get_by(Address, Map.to_list(address_1)) do
  changeset = Address.changeset(%Address{}, address_1)
  Repo.insert(changeset)
end

# Competitions
competition_names = ["League 1", "League 2", "Super Cup"]
for competition_name -> competition_names do
  unless Repo.get_by(Competition, name: competition_name) do
    changeset = Competition.changeset(%Competition{}, %{name: competition_name})
    Repo.insert(changeset)
  end
end

# MeetingPoint
unless Repo.get_by(MeetingPoint, id: 1) do
  address = Repo.one(Address)
  changeset = MeetingPoint.changeset(%MeetingPoint{}, %{address_id: address.id, name: "My Club"})
  Repo.insert(changeset)
end

# News
unless Repo.get(News, 1) do
  changeset = News.changeset(%News{}, %{public: true, subject: "News Subject 1", body: "News Message 1"})
  Repo.insert(changeset)
end
unless Repo.get(News, 2) do
  changeset = News.changeset(%News{}, %{public: true, subject: "News Subject 2", body: "News Message 2"})
  Repo.insert(changeset)
end

#Opponent Teams
opponent_team_1 = %{name: "Opponent Team 1"}
unless Repo.get_by(OpponentTeam, name: Map.to_list(opponent_team_1)) do
  changeset = OpponentTeam.changeset(%OpponentTeam{}, opponent_team_1)
  Repo.insert(changeset)
end
opponent_team_2 = %{name: "Opponent Team 2"}
unless Repo.get_by(OpponentTeam, name: Map.to_list(opponent_team_2)) do
  changeset = OpponentTeam.changeset(%OpponentTeam{}, opponent_team_2)
  Repo.insert(changeset)
end
opponent_team_3 = %{name: "Opponent Team 3"}
unless Repo.get_by(OpponentTeam, name: Map.to_list(opponent_team_3)) do
  changeset = OpponentTeam.changeset(%OpponentTeam{}, opponent_team_3)
  Repo.insert(changeset)
end

# Seasons
season_1 = %{name: "2015-2016"}
unless Repo.get_by(Season, name: Map.to_list(season_1)) do
  changeset = Season.changeset(%Season{}, season_1)
  Repo.insert(changeset)
end
season_2 = %{name: "2016-2017"}
unless Repo.get_by(Season, name: Map.to_list(season_2)) do
  changeset = Season.changeset(%Season{}, season_2)
  Repo.insert(changeset)
end

# Teams
club_name = "My Club Name"
club_permalink = "my-club-name"
unless Repo.get_by(Team, rewrite: "#{club_permalink}-men") do
  competition = Repo.get_by!(Competition, name: "League 1")
  changeset = Team.changeset(%Team{}, %{competition_id: competition.id, name: "#{club_name} Men"})
  Repo.insert(changeset)
end
unless Repo.get_by(Team, rewrite: "#{club_permalink}-men-2") do
  competition = Repo.get_by!(Competition, name: "League 2")
  changeset = Team.changeset(%Team{}, %{competition_id: competition.id, name: "#{club_name} Men 2"})
  Repo.insert(changeset)
end

# Text Pages (Static Sites)
text_pages_keys = [
  "/about-us.html",
  "/chronicle.html",
  "/contact.html",
  "/registration-information.html",
  "/sponsors.html"
]
for text_page_key <- text_pages_keys do
  unless Repo.get_by(TextPage, key: text_page_key) do
    changeset = TextPage.changeset(%TextPage{}, text_page_key)
    Repo.insert(changeset)
  end 
end

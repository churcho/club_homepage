use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :club_homepage, ClubHomepage.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

## Configure your database
#config :club_homepage, ClubHomepage.Repo,
#  adapter: Ecto.Adapters.Postgres,
#  username: "postgres",
#  password: "postgres",
#  database: "club_homepage_test",
#  hostname: "localhost",
#  pool: Ecto.Adapters.SQL.Sandbox
# Configure your database
config :club_homepage, ClubHomepage.Repo,
  adapter: Sqlite.Ecto,
  database: "db/club_homepage_test.sqlite",
  pool: Ecto.Adapters.SQL.Sandbox

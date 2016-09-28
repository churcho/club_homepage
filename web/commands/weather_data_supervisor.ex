defmodule ClubHomepage.WeatherData.Supervisor do
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_opts) do
    children = [
      worker(ClubHomepage.WeatherData, [nil], restart: :permanent)
    ]
    supervise children, strategy: :one_for_one
  end
end

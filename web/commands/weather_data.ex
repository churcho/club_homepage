defmodule ClubHomepage.WeatherData do
  @moduledoc """
  
  """

  use Number

  @doc """
  """
  def get do
    # {:ok, %{centigrade: 7.8, created_at: 1476902712, fahrenheit: 46.04, weather: "leichter Regen", wind_in_kilometers_per_hour: 18.0, wind_in_meters_per_second: 5.1}}
    ElixirWeatherData.get
    |> format_temperature
    |> format_wind
    |> format_created_at
  end

  defp format_temperature({:error, _}), do: {:error, %{}}
  defp format_temperature({:ok, data}) do
    key = :centigrade
    {number, _key} = Map.pop(data, key)

    result =
      data
      |> Map.drop([:centigrade, :fahrenheit])
      |> Map.put_new(:temperature, Number.Delimit.number_to_delimited(number, precision: 1) <> " °C")
    {:ok, result}
  end

  defp format_wind({:error, _}), do: {:error, %{}}
  defp format_wind({:ok, data}) do
    key = :wind_in_kilometers_per_hour
    {number, _key} = Map.pop(data, key)

    result =
      data
      |> Map.drop([:wind_in_kilometers_per_hour, :wind_in_meters_per_second])
      |> Map.put_new(:wind_speed, Number.Delimit.number_to_delimited(number, precision: 0) <> " km/h")
    {:ok, result}
  end

  defp format_created_at({:error, _}), do: {:error, %{}}
  defp format_created_at({:ok, data}) do
    {:ok, Map.put(data, :created_at, DateTime.Convert.from_timestamp(data[:created_at]))}
  end
end
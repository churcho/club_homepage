defmodule ClubHomepage.LayoutView do
  use ClubHomepage.Web, :view

  def my_payment_lists_popover_content(conn, payment_lists) do
    links = ["<a href=\"#{payment_list_path(conn, :new)}\" class=\"list-group-item\">#{gettext("create_payment_list")}</a>" | payment_list_link(conn, payment_lists)]
    "<div class=\"list-group\">" <> Enum.join(links) <> "</div>"
  end
  defp payment_list_link(_conn, []), do: []
  defp payment_list_link(conn, [payment_list | payment_lists]) do
    ["<a href=\"#{payment_list_path(conn, :show, payment_list)}\" class=\"list-group-item\"><span>#{payment_list.id}</span></a>" |  payment_list_link(conn, payment_lists)]
  end

  def weather_data_popover_content(weather_data) do
    {:ok, date_string} = Timex.format(weather_data[:created_at], datetime_format(), :strftime)
    "<div class=\"row popover-content-box\">
      <div class=\"col-xs-12 text-center\">#{date_string} #{gettext("o_clock")}</div>
      <div class=\"col-xs-12 text-center\">#{weather_data[:weather]}<br /><br /></div>

      <div class=\"col-xs-6\"><small>#{gettext("temperature")}:</small></div>
      <div class=\"col-xs-6\">#{weather_data[:temperature]}</div>

      <div class=\"col-xs-6\"><small>Wind:</small></div>
      <div class=\"col-xs-6\">#{weather_data[:wind_speed]} #{wind_direction_abbrevation(weather_data)}</div>

      <div class=\"col-xs-6\"><small>#{gettext("humidity")}:</small></div>
      <div class=\"col-xs-6\">#{weather_data[:humidity_in_percent]} %</div>

      <div class=\"col-xs-6\"><small>#{gettext("air_pressure")}:</small></div>
      <div class=\"col-xs-6\">#{weather_data[:pressure_in_hectopascal]} hPa</div>
    </div>"
  end
  
  defp wind_direction_abbrevation(weather_data) do
    if weather_data[:wind_direction_abbreviation] != "" do
      Gettext.dgettext(ClubHomepage.Gettext, "additionals", "wind_direction_abbreviation_#{weather_data[:wind_direction_abbreviation]}")
    end
  end




  def javascript_localization_options do
    ClubHomepage.JavascriptLocalization.run
    |> to_json
  end

  def to_json(object) do
    case JSON.encode(object) do
      {:ok, json} -> json
      _           -> ""
    end
  end
end

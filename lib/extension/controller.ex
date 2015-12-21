defmodule Extension.Controller do
  def parse_date_field(params, field, format \\ "%d.%m.%Y") do
    field_name = Atom.to_string(field)

    params  
    |> extract_value(field_name)
    |> check_value
    |> parse_value(field_name, format)
  end

  defp extract_value(params, field_name), do: {:ok, params, params[field_name]}

  defp check_value({:ok, params, nil}), do: {:empty, params, nil}
  defp check_value({:ok, params, value}), do: {:ok, params, value}

  defp parse_value({:empty, params, nil}, _field_name, _format), do: params
  defp parse_value({:ok, params, value}, field_name, format) do
    case Timex.DateFormat.parse(value, format, :strftime) do 
      {:ok, timex_datetime} -> Map.put(params, field_name, timex_datetime)
      _ -> Map.put(params, field_name, nil)
    end
  end
end
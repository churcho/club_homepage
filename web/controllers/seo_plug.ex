defmodule ClubHomepage.SEO.Plug do
  import Plug.Conn
  import ClubHomepage.Extension.Controller, only: [full_club_name: 0]

  def put_seo(%{private: %{phoenix_action: action_name, phoenix_controller: controller}} = conn, _options) do
    controller_name = extract_controller_name(controller)
    settings = apply(__MODULE__, controller_name, [controller, action_name]) || []

    conn
    |> assign(:title, (settings[:title] || full_club_name))
    |> assign(:meta, (settings[:meta] || ""))
  end

  def page_controller(controller, action_name) do
    controller_name = extract_controller_name(controller)
    %{
        title: gettext("title_#{controller_name}_#{action_name}", full_club_name: full_club_name),
        meta: gettext("meta_#{controller_name}_#{action_name}", full_club_name: full_club_name)
      }
  end

  defp extract_controller_name(controller) do
    controller
    |> Atom.to_string
    |> String.split(".")
    |> List.last
    |> Macro.underscore
    |> String.to_atom
  end

  defp gettext(text, options) do
    Gettext.dgettext(ClubHomepage.Gettext, "meta", text, options)
  end
end

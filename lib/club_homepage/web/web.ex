defmodule ClubHomepage.Web do
  @moduledoc """
  A module that keeps using definitions for controllers,
  views and so on.

  This can be used in your application as:

      use ClubHomepage.Web, :controller
      use ClubHomepage.Web, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below.
  """

  def model do
    quote do
      use Ecto.Schema
      use Timex.Ecto.Timestamps

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
    end
  end

  def controller do
    quote do
      use Phoenix.Controller, namespace: ClubHomepage.Web

      alias ClubHomepage.Repo
#      import Ecto.Schema
      import Ecto
      import Ecto.Query

      import ClubHomepage.Web.Router.Helpers
      import ClubHomepage.Web.Gettext
      import ClubHomepage.Web.Localization

      import ClubHomepage.Extension.Controller
      import ClubHomepage.Extension.CommonMatch, only: [failure_reasons: 0, internal_user_name: 1]
      import ClubHomepage.Extension.CommonSeason
      import ClubHomepage.Extension.CommonTimex
      import ClubHomepage.Web.Auth, only: [authenticate_user: 2, require_no_user: 2, current_user: 1, logged_in?: 1, logged_in?: 2]
      import ClubHomepage.Web.AuthByRole, only: [has_role?: 2, is_administrator?: 2, is_match_editor?: 2, is_member?: 2, is_news_editor?: 2, is_player?: 2, is_team_editor?: 2, is_text_page_editor?: 2, is_user_editor?: 2, has_role_from_list?: 2]

      import ClubHomepage.Web.SEO.Plug
    end
  end

  def view do
    quote do
      use Phoenix.View, root: "lib/club_homepage/web/templates"

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_csrf_token: 0, get_flash: 2, view_module: 1, action_name: 1, controller_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import ClubHomepage.Web.Router.Helpers
      import ClubHomepage.Web.ErrorHelpers
      import ClubHomepage.Web.Gettext
      import ClubHomepage.Web.Localization

      import ClubHomepage.Extension.View
      import ClubHomepage.Extension.CommonMatch, only: [failure_reasons: 0, internal_user_name: 1]
      import ClubHomepage.Extension.CommonSeason
      import ClubHomepage.Extension.CommonTimex
      import ClubHomepage.Web.Auth, only: [logged_in?: 1, current_user: 1]
      import ClubHomepage.Web.UserRole, only: [has_role?: 2]
    end
  end

  def router do
    quote do
      use Phoenix.Router

      import ClubHomepage.Web.Auth, only: [authenticate_user: 2, current_user: 1]
      import ClubHomepage.Web.AuthByRole, only: [is_administrator?: 2, is_match_editor?: 2, is_member?: 2, is_news_editor?: 2, is_player?: 2, is_team_editor?: 2, is_text_page_editor?: 2, is_user_editor?: 2]
    end
  end

  def channel do
    quote do
      use Phoenix.Channel

      alias ClubHomepage.Repo
#      import Ecto.Schema
      import Ecto
      import Ecto.Query
      import ClubHomepage.Web.Gettext
      import ClubHomepage.Web.Localization

      import ClubHomepage.Extension.CommonMatch, only: [internal_user_name: 1]
    end
  end
  
  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
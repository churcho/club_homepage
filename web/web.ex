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
      import Ecto.Query, only: [from: 1, from: 2]
    end
  end

  def controller do
    quote do
      use Phoenix.Controller

      alias ClubHomepage.Repo
      import Ecto.Schema
      import Ecto
      import Ecto.Query, only: [from: 1, from: 2]

      import ClubHomepage.Router.Helpers
      import ClubHomepage.Extension.Controller
      import ClubHomepage.Extension.CommonSeason
      import ClubHomepage.Extension.CommonTimex
      import ClubHomepage.Auth, only: [authenticate_user: 2]
      import ClubHomepage.AuthByRole, only: [is_administrator?: 2, is_match_editor?: 2, is_member?: 2, is_news_editor?: 2, is_player?: 2, is_text_page_editor?: 2, is_trainer?: 2]
      import ClubHomepage.UserRole, only: [has_role?: 2]
    end
  end

  def view do
    quote do
      use Phoenix.View, root: "web/templates"

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_csrf_token: 0, get_flash: 2, view_module: 1, action_name: 1, controller_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import ClubHomepage.Router.Helpers
      import ClubHomepage.ErrorHelpers
      import ClubHomepage.Gettext
      import ClubHomepage.Extension.View
      import ClubHomepage.Extension.CommonSeason
      import ClubHomepage.Extension.CommonTimex
      import ClubHomepage.UserRole, only: [has_role?: 2]
    end
  end

  def router do
    quote do
      use Phoenix.Router

      import ClubHomepage.Auth, only: [authenticate_user: 2]
      import ClubHomepage.AuthByRole, only: [is_administrator?: 2, is_match_editor?: 2, is_member?: 2, is_news_editor?: 2, is_player?: 2, is_text_page_editor?: 2, is_trainer?: 2]
    end
  end

  def channel do
    quote do
      use Phoenix.Channel

      alias ClubHomepage.Repo
      import Ecto.Schema
      import Ecto
      import Ecto.Query, only: [from: 1, from: 2]
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end

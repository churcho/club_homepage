defmodule ClubHomepage.UserRole do
  @moduledoc """

  """

  alias Ecto.Changeset

  # member  - simple a member of the club, a rigistered user
  # player  - an active sports men/woman
  # trainer - responsible for a team
  # editor  - reporter of game/match results, author of news
  # administrator - has all rights
  @roles ~w(administrator member player trainer editor)

  @doc """
  Checks wether a ClubHomepage.User has a user role. Return true or false.
  """
  @spec has_role?( ClubHomepage.User, String ) :: Boolean
  def has_role?(user, role) do
    roles = split(user.roles)
    include?(roles, role) && valid?(role)
  end

  #@spec include?( List(String), String ) :: Boolean
  defp include?(roles, role) do
    Enum.member?(roles, role)
  end

  @spec valid?( String ) :: Boolean
  defp valid?(role) do
    Enum.member?(@roles, role)
  end



  @doc """
  Validates a ClubHomepage.User changeset. It checks that defined user roles are in the roles attribute only and it checks, that the user roles include the member role.
  """
  @spec check_roles( Ecto.Changeset ) :: Ecto.Changeset
  def check_roles(%{model: model, changes: changes} = changeset) do
    changeset
    |> check_current_roles(model)
    |> check_changes(changes)
  end

  defp check_current_roles(changeset, model) do
    case model.roles do
      nil -> Changeset.put_change(changeset, :roles, "member")
      _   -> changeset
    end
  end

  defp check_changes(changeset, changes) do
    case changes[:roles] do
      nil -> changeset
      _   -> Changeset.put_change(changeset, :roles, clean_up_roles(changes.roles))
    end
  end

  defp clean_up_roles(roles) do
    roles
    |> split
    |> Enum.filter(fn(s) -> Enum.member?(@roles, s) end)
    |> Enum.uniq
    |> ensure_member_role_exists
    |> Enum.join(" ")
  end

  defp ensure_member_role_exists(roles) do
    case Enum.member?(roles, "member") do
      false -> ["member" | roles]
      _     -> roles
    end
  end




  #@spec split ( String ) :: List(String)
  defp split(roles) do
    roles
    |> String.split
    |> Enum.map(fn(s) -> String.strip(s) end)
  end
end

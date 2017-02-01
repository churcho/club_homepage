defmodule ClubHomepage.User do
  use ClubHomepage.Web, :model

  #alias ClubHomepage.ModelValidator
  alias ClubHomepage.UserRole

  schema "users" do
    field :active, :boolean
    field :birthday, Timex.Ecto.DateTime
    field :login, :string
    field :email, :string
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
    field :password_hash, :string
    field :name, :string
    field :nickname, :string
    field :roles, :string
    field :meta_data, :map
    field :token, :string
    field :token_set_at, Timex.Ecto.DateTime
    field :mobile_phone, :string

    has_many :team_chat_messages, ClubHomepage.TeamChatMessage

    timestamps
  end

  def unregistered_changeset(model, params \\ %{}) do
    model
    |> cast(params, ~w(email name), ~w(nickname login birthday active roles meta_data token token_set_at mobile_phone))
    |> validate_length(:name, max: 100)
    |> check_email
    |> UserRole.check_roles
    |> set_active(false)
  end

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> unregistered_changeset(params)
    |> cast(params, ~w(login birthday mobile_phone), [])
    |> validate_length(:login, min: 6)
    |> validate_length(:login, max: 20)
    |> validate_format(:login, ~r/\A[a-z0-9._-]+\z/i)
    |> update_change(:login, &String.downcase/1)
    |> unique_constraint(:login)
    |> validate_format(:mobile_phone, ~r/\A([\+][0-9]{1,3}[ \.\-])?([\(]{1}[0-9]{1,6}[\)])?([0-9 \.\-\/]{3,20})((x|ext|extension)[ ]?[0-9]{1,4})?\z/i)
    #|> ModelValidator.validate_uniqueness(:login)
  end

  def registration_changeset(model, params) do
    model
    |> changeset(params)
    |> cast(params, ~w(password password_confirmation), [])
    |> validate_length(:password, min: 6, max: 100)
    |> validate_length(:password_confirmation, min: 6, max: 100)
    |> validate_confirmation(:password)
    |> put_pass_hash()
    |> set_active(true)
  end

  defp put_pass_hash(%Ecto.Changeset{valid?: true, changes: %{password: pass}} = changeset) do
    put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(pass))
  end
  defp put_pass_hash(changeset), do: changeset

  defp set_active(%Ecto.Changeset{data: %ClubHomepage.User{active: nil}} = changeset, state) do
    changeset
    |> put_change(:active, state)
  end
  defp set_active(changeset, _state), do: changeset

  defp check_email(%Ecto.Changeset{data: %ClubHomepage.User{email: nil}} = changeset) do
    changeset
    |> validate_format(:email, ~r/\A[A-Z0-9_\.&%\+\-\']+@(?:[A-Z0-9\-]+\.)+(?:[A-Z]{2,13})\z/i)
    |> update_change(:email, &String.downcase/1)
    |> unique_constraint(:email)
    #|> ModelValidator.validate_uniqueness(:email)
  end
  defp check_email(changeset) do
    changeset
    |> validate_format(:email, ~r/\A[A-Z0-9_\.&%\+\-\']+@(?:[A-Z0-9\-]+\.)+(?:[A-Z]{2,13})\z/i)
    |> update_change(:email, &String.downcase/1)
  end
end

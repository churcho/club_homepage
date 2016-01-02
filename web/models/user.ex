defmodule ClubHomepage.User do
  use ClubHomepage.Web, :model

  alias ClubHomepage.ModelValidator

  schema "users" do
    field :active, :boolean
    field :birthday, Timex.Ecto.DateTime
    field :login, :string
    field :email, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    field :name, :string
    field :roles, :string

    timestamps
  end

  def unregistered_changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(email name), ~w(login birthday active roles))
    |> validate_length(:name, max: 100, message: "ist zu lang (max. 100 Zeichen)")
    |> check_email
    |> set_roles
    |> set_active(false)
  end

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> unregistered_changeset(params)
    |> cast(params, ~w(login birthday), [])
    |> validate_length(:login, min: 6, message: "ist zu kurz (min. 6, max. 20 Zeichen)")
    |> validate_length(:login, max: 20, message: "ist zu lang (min. 6, max. 20 Zeichen)")
    |> validate_format(:login, ~r/\A[a-z0-9._-]+\z/i, message: "enthält ungültige Zeichen (gültig: 0-9 a-z . _ -)")
    |> update_change(:login, &String.downcase/1)
    |> ModelValidator.validate_uniqueness(:login, message: "ist bereits vergeben")
  end

  def registration_changeset(model, params) do
    model
    |> changeset(params)
    |> cast(params, ~w(password), [])
    |> validate_length(:password, min: 6, max: 100, message: "mindestens 1 und maximal 100 Zeichen")
    |> put_pass_hash()
    |> set_active(true)
  end

  defp put_pass_hash(%Ecto.Changeset{valid?: true, changes: %{password: pass}} = changeset) do
    put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(pass))
  end
  defp put_pass_hash(changeset), do: changeset

  defp set_active(%Ecto.Changeset{model: %ClubHomepage.User{active: nil}} = changeset, state) do
    changeset
    |> put_change(:active, state)
  end
  defp set_active(changeset, _state), do: changeset

  defp set_roles(%Ecto.Changeset{model: %ClubHomepage.User{roles: nil}} = changeset) do
    changeset
    |> put_change(:roles, "member")
  end
  defp set_roles(changeset), do: changeset

  defp check_email(%Ecto.Changeset{model: %ClubHomepage.User{email: nil}} = changeset) do
    changeset
    |> validate_format(:email, ~r/\A[A-Z0-9_\.&%\+\-\']+@(?:[A-Z0-9\-]+\.)+(?:[A-Z]{2,13})\z/i, message: "hat ein ungültiges Format")
    |> update_change(:email, &String.downcase/1)
    |> ModelValidator.validate_uniqueness(:email, message: "ist bereits vergeben")
  end
  defp check_email(changeset) do
    changeset
    |> validate_format(:email, ~r/\A[A-Z0-9_\.&%\+\-\']+@(?:[A-Z0-9\-]+\.)+(?:[A-Z]{2,13})\z/i, message: "hat ein ungültiges Format")
    |> update_change(:email, &String.downcase/1)
  end
end

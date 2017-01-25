defmodule ClubHomepage.UserController do
  use ClubHomepage.Web, :controller

  alias ClubHomepage.User
  alias ClubHomepage.Auth
  alias ClubHomepage.UserRole

  plug :is_user_editor? when action in [:index, :show, :new_unregistered, :create_unregistered, :edit, :update, :delete]
  plug :scrub_params, "user" when action in [:create, :update]
  plug :require_no_user when action in [:new, :create, :forgot_password_step_1, :forgot_password_step_2, :change_password, :reset_password]

  def index(conn, _params) do
    users = Repo.all(User)
    render(conn, "index.html", users: users)
  end

  def show(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    render(conn, "show.html", user: user)
  end

  def new_unregistered(conn, _params) do
    changeset = User.unregistered_changeset(%User{})
    render(conn, "new_unregistered.html", changeset: changeset)
  end

  def create_unregistered(conn, %{"user" => user_params}) do
    user_params = parse_date_field(user_params, :birthday)
    changeset = User.unregistered_changeset(%User{}, user_params)
    case Repo.insert(changeset) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, gettext("user_created_successfully"))
        |> redirect(to: unregistered_user_path(conn, :new_unregistered))
      {:error, changeset} ->
        render(conn, "new_unregistered.html", changeset: changeset)
    end
  end

  def new(conn, params) do
    changeset = User.changeset(%User{})
    render(conn, "new.html", changeset: changeset, secret: params["secret"],
           user: nil,
           editable_user_roles: UserRole.editable_roles(current_user(conn)),
           current_user_roles: [])
  end

  def create(conn, %{"user" => user_params}) do
    user_params = parse_date_field(user_params, :birthday)
    secret_key  = user_params["secret"]

    user =
      case user_params["email"] do
        nil -> nil
        email -> Repo.get_by(User, email: email)
      end

    result = get_registration_changeset(user, user_params, secret_key)
    case result do
      {:ok, user} ->
        ClubHomepage.SecretCheck.delete(secret_key)
        conn
        |> Auth.login(user)
        |> put_flash(:info, gettext("user_created_successfully_and_loged_in"))
        |> redirect(to: page_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset, secret: secret_key,
               user: nil,
               editable_user_roles: UserRole.editable_roles(current_user(conn)),
               current_user_roles: [])
    end
  end

  def edit(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    changeset = User.changeset(user)
    render(conn, "edit.html", changeset: changeset,
           user: user,
           editable_user_roles: UserRole.editable_roles(current_user(conn)),
           current_user_roles: UserRole.split(user.roles))
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Repo.get!(User, id)

    user_params =
      user_params
      |> parse_date_field(:birthday)
      |> join_user_roles(user, conn)

    changeset = User.changeset(user, user_params)

    case Repo.update(changeset) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, gettext("user_updated_successfully"))
        |> redirect(to: managed_user_path(conn, :index))
      {:error, changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset,
               editable_user_roles: UserRole.editable_roles(current_user(conn)),
               current_user_roles: UserRole.split(user.roles))
    end
  end

  # def delete(conn, %{"id" => id}) do
  #   user = Repo.get!(User, id)

  #   # Here we use delete! (with a bang) because we expect
  #   # it to always work (and if it does not, it will raise).
  #   Repo.delete!(user)

  #   conn
  #   |> put_flash(:info, gettext("user_deleted_successfully"))
  #   |> redirect(to: user_path(conn, :index))
  # end

  def forgot_password_step_1(conn, _) do
    render(conn, "forgot_password_step_1.html")
  end
  def forgot_password_step_2(conn, %{"forgot_password" => %{"login_or_email" => login_or_email}}) do
    user = Repo.one(from(u in User, where: (u.login == ^login_or_email) or (u.email == ^login_or_email)))
    case user do
      nil ->
        conn
        |> put_flash(:error, gettext("account_not_found"))
        |> redirect(to: forgot_password_path(conn, :forgot_password_step_1))
      user ->
        user = change_user_token(user)
        IO.inspect user
        conn
        |> ClubHomepage.Email.forgot_password_email(user)
        |> ClubHomepage.Mailer.deliver_now
        render(conn, "forgot_password_step_2.html", user: user)
    end
  end

  def change_password(conn, %{"id" => id, "token" => token}) do
    user = Repo.get_by!(User, %{"id" => id, "token" => token})
    render(conn, "change_password.html", user: user)
  end

  def reset_password(conn, %{"id" => id, "token" => token, "password" => password, "password_confirmation" => password_confirmation}) do
    user = Repo.get_by!(User, %{"id" => id, "token" => token})
    changeset = User.changeset(user, %{"password" => password, "password_confirmation" => password_confirmation, "token" => nil})
    case Repo.update(changeset) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, gettext("user_updated_successfully"))
        |> redirect(to: managed_user_path(conn, :index))
      {:error, _changeset} ->
        render(conn, "reset_password_failure.html", user: user)
    end
  end

  defp get_registration_changeset(nil, user_params, secret_key) do
    changeset =
      User.registration_changeset(%User{}, user_params)
      |> ClubHomepage.SecretCheck.run(secret_key)
    Repo.insert(changeset)
  end
  defp get_registration_changeset(user, user_params, secret_key) do
    changeset =
      User.registration_changeset(user, user_params)
      |> ClubHomepage.SecretCheck.run(secret_key)
    Repo.update(changeset)
  end

  defp join_user_roles(%{"roles" => roles} = user_params, edited_user, conn) when is_list(roles) do
    new_roles = UserRole.new_roles(edited_user, roles, current_user(conn))
    user_params
    |> Map.put("roles", Enum.join(new_roles, " "))
  end
  defp join_user_roles(user_params, _edited_user, _conn), do: user_params

  defp change_user_token(user) do
    token = :crypto.hash(:sha256, "#{Timex.to_unix(Timex.now)}") |> Base.encode16
    IO.inspect token
    user_params = 
      %{"token" => token, "token_set_at" => Timex.now}
      |> parse_date_field(:token_set_at)
    IO.inspect user_params
    changeset = User.changeset(user, user_params)
    case Repo.update(changeset) do
      {:ok, user} -> user
      {:error, _changeset} -> user
    end
  end
end

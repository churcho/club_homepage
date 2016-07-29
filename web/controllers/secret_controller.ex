defmodule ClubHomepage.SecretController do
  use ClubHomepage.Web, :controller

  alias ClubHomepage.Secret

  plug :is_user_editor?
  plug :scrub_params, "secret" when action in [:update]

  def index(conn, _params) do
    secrets = Repo.all(Secret)
    render(conn, "index.html", secrets: secrets)
  end

  def show(conn, %{"id" => id}) do
    secret = Repo.get!(Secret, id)
    render(conn, "show.html", secret: secret)
  end

  def new(conn, _params) do
    changeset = Secret.changeset(%Secret{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, _) do
    changeset = Secret.changeset(%Secret{}, %{})

    case Repo.insert(changeset) do
      {:ok, secret} ->
        conn
        |> put_flash(:info, gettext("secret_created_successfully"))
        |> redirect(to: secret_path(conn, :show, secret))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    secret = Repo.get!(Secret, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(secret)

    conn
    |> put_flash(:info, gettext("secret_deleted_successfully"))
    |> redirect(to: secret_path(conn, :index))
  end
end

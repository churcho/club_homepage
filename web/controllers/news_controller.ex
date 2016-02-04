defmodule ClubHomepage.NewsController do
  use ClubHomepage.Web, :controller

  alias ClubHomepage.News

  plug :scrub_params, "news" when action in [:create, :update]

  def index(conn, _params) do
    news = Repo.all(News)
    render(conn, "index.html", news: news)
  end

  def index_public(conn, _params) do
    news = Repo.all(from(n in News, order_by: [desc: n.inserted_at], where: n.public == true))
    render(conn, "index_public.html", news: news)
  end

  def new(conn, _params) do
    changeset = News.changeset(%News{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"news" => news_params}) do
    changeset = News.changeset(%News{}, news_params)

    case Repo.insert(changeset) do
      {:ok, _news} ->
        conn
        |> put_flash(:info, "News created successfully.")
        |> redirect(to: news_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    news = Repo.get!(News, id)
    render(conn, "show.html", news: news)
  end

  def show_public(conn, %{"id" => id}) do
    news = Repo.get_by!(News, id: id, public: true)
    render(conn, "show_public.html", news: news)
  end

  def edit(conn, %{"id" => id}) do
    news = Repo.get!(News, id)
    changeset = News.changeset(news)
    render(conn, "edit.html", news: news, changeset: changeset)
  end

  def update(conn, %{"id" => id, "news" => news_params}) do
    news = Repo.get!(News, id)
    changeset = News.changeset(news, news_params)

    case Repo.update(changeset) do
      {:ok, news} ->
        conn
        |> put_flash(:info, "News updated successfully.")
        |> redirect(to: news_path(conn, :show, news))
      {:error, changeset} ->
        render(conn, "edit.html", news: news, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    news = Repo.get!(News, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(news)

    conn
    |> put_flash(:info, "News deleted successfully.")
    |> redirect(to: news_path(conn, :index))
  end
end

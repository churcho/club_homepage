defmodule ClubHomepage.MatchControllerTest do
  use ClubHomepage.ConnCase

  alias ClubHomepage.Match

  import ClubHomepage.Factory

  import Ecto.Query, only: [from: 1, from: 2]

  @valid_attrs %{season_id: 1, team_id: 1, opponent_team_id: 1, home_match: true, start_at: "17.04.2010 14:00"}
  @invalid_attrs %{}

  setup context do
    conn = conn()
    season        = create(:season)
    team          = create(:team)
    opponent_team = create(:opponent_team)
    valid_attrs = %{@valid_attrs | season_id: season.id, team_id: team.id, opponent_team_id: opponent_team.id}
    if context[:login] do
      current_user = create(:user)
      conn = assign(conn, :current_user, current_user)
      {:ok, conn: conn, current_user: current_user, valid_attrs: valid_attrs}
    else
      {:ok, conn: conn, valid_attrs: valid_attrs}
    end
  end

  @tag login: false
  test "requires user authentication on all actions", %{conn: conn, valid_attrs: valid_attrs} do
    match = create(:match)
    Enum.each([
      get(conn, match_path(conn, :index)),
      get(conn, match_path(conn, :new)),
      post(conn, match_path(conn, :create), match: valid_attrs),
      get(conn, match_path(conn, :show, match)),
      get(conn, match_path(conn, :edit, match)),
      put(conn, match_path(conn, :update, match), match: valid_attrs),
      delete(conn, match_path(conn, :delete, match))
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
      assert redirected_to(conn) =~ "/"
    end)
  end

  @tag login: true
  test "lists all entries on index with a user is logged in", %{conn: conn, current_user: _current_user, valid_attrs: _valid_attrs} do
    conn = get conn, match_path(conn, :index)
    assert html_response(conn, 200) =~ "All Matches"
  end

  @tag login: true
  test "renders form for new resources with a user is logged in", %{conn: conn, current_user: _current_user, valid_attrs: _valid_attrs} do
    conn = get conn, match_path(conn, :new)
    assert html_response(conn, 200) =~ "Create Match"
  end

  @tag login: true
  test "creates a match and redirects when data is valid and a user is logged in", %{conn: conn, current_user: _current_user, valid_attrs: valid_attrs} do
    query = from(m in Match, select: count(m.id))
    assert 0 == Repo.one(query)
    conn = post conn, match_path(conn, :create), match: valid_attrs

    {:ok, start_at} =
      valid_attrs.start_at
      |> Timex.DateFormat.parse("%d.%m.%Y %H:%M", :strftime) 
    {:ok, start_at} =
      start_at
      |> Timex.Date.add(Timex.Time.to_timestamp(7, :days))
      |> Timex.DateFormat.format("%d.%m.%Y %H:%M", :strftime)
    assert redirected_to(conn) == match_path(conn, :index, %{"season_id" => valid_attrs.season_id, "team_id" => valid_attrs.team_id, "start_at" => start_at})
    assert 1 == Repo.one(query)
  end

  @tag login: true
  test "does not create a match and renders errors when data is invalid and a user is logged in", %{conn: conn, current_user: _current_user, valid_attrs: _valid_attrs} do
    conn = post conn, match_path(conn, :create), match: @invalid_attrs
    assert html_response(conn, 200) =~ "Create Match"
  end

  @tag login: true
  test "shows a match with a user is logged in", %{conn: conn, current_user: _current_user, valid_attrs: _valid_attrs} do
    match = create(:match)
    team = Repo.get!(ClubHomepage.Team, match.team_id)
    opponent_team = Repo.get!(ClubHomepage.OpponentTeam, match.opponent_team_id)
    conn = get conn, match_path(conn, :show, match)
    headline = 
      if match.home_match do
        team.name <> " - " <> opponent_team.name
      else
        opponent_team.name <> " - " <> team.name
      end
    assert html_response(conn, 200) =~ headline
  end

  @tag login: true
  # test "tries to render page not found when id is nonexistent and no user is logged in", %{conn: conn, current_user: _current_user, valid_attrs: _valid_attrs} do
  #   #assert_error_sent 404, fn ->
  #     get conn, match_path(conn, :show, -1)
  #   #end
  #   IO.inspect conn
  #   assert redirected_to(conn) =~ "/"
  # end

  @tag login: true
  test "renders page not found when id is nonexistent and a user is logged in", %{conn: conn, current_user: _current_user, valid_attrs: _valid_attrs} do
    assert_raise Ecto.NoResultsError, fn ->
      get conn, match_path(conn, :show, -1)
    end
  end

  @tag login: true
  test "renders form for editing chosen resource with a user is logged in", %{conn: conn, current_user: _current_user, valid_attrs: _valid_attrs} do
    match = Repo.insert! %Match{}
    conn = get conn, match_path(conn, :edit, match)
    assert html_response(conn, 200) =~ "Edit Match"
  end

  @tag login: true
  test "updates chosen resource and redirects when data is valid and a user is logged in", %{conn: conn, current_user: _current_user, valid_attrs: valid_attrs} do
    query = from(m in Match, select: count(m.id), where: m.home_match == true)

    assert 0 == Repo.one(query)

    match = Repo.insert! %Match{home_match: true}
    assert match.home_match == true
    assert 1 == Repo.one(query)

    attributes = %{valid_attrs | home_match: false}
    conn = put conn, match_path(conn, :update, match), match: attributes
    assert redirected_to(conn) == match_path(conn, :show, match)

    updated_match = Repo.get_by(Match, id: match.id)
    assert updated_match
    assert updated_match.home_match == false
    assert 0 == Repo.one(query)
  end

  @tag login: true
  test "does not update chosen resource and renders errors when data is invalid a user is logged in", %{conn: conn, current_user: _current_user, valid_attrs: _valid_attrs} do
    match = Repo.insert! %Match{}
    conn = put conn, match_path(conn, :update, match), match: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit Match"
  end

  @tag login: true
  test "deletes chosen resource with a user is logged in", %{conn: conn, current_user: _current_user, valid_attrs: _valid_attrs} do
    match = Repo.insert! %Match{}
    conn = delete conn, match_path(conn, :delete, match)
    assert redirected_to(conn) == match_path(conn, :index)
    refute Repo.get(Match, match.id)
  end

  def prepare_next_match_parameters(%{"season_id" => season_id, "team_id" => team_id, "start_at" => start_at}) do
    %{"season_id" => season_id, "team_id" => team_id, "start_at" => start_at}
  end
end

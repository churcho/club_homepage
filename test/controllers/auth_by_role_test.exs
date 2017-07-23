defmodule ClubHomepage.Web.AuthByRoleTest do
  use ClubHomepage.Web.ConnCase
  alias ClubHomepage.Web.AuthByRole

  setup do
    conn =
      build_conn()
      |> bypass_through(ClubHomepage.Web.Router, :browser)
      |> get("/")
    {:ok, %{conn: conn}}
  end

  test "is_administrator? halts when no current_user exists", %{conn: conn} do
    conn = AuthByRole.is_administrator?(conn, [])
    assert flash_messages_contain?(conn, "You are not authorized to view this page.")
    assert conn.halted
  end

  test "is_administrator? halts when current_user has no administrator role", %{conn: conn} do
    conn =
      conn
      |> assign(:current_user, %ClubHomepage.User{roles: "member player"})
      |> AuthByRole.is_administrator?([])
    assert flash_messages_contain?(conn, "You are not authorized to view this page.")
    assert conn.halted
  end

  test "is_administrator? continues when the current_user has the administrator role", %{conn: conn} do
    conn =
      conn
      |> assign(:current_user, %ClubHomepage.User{roles: "member administrator player"})
      |> AuthByRole.is_administrator?([])
    refute conn.halted
  end



  test "is_match_editor? halts when no current_user exists", %{conn: conn} do
    conn = AuthByRole.is_match_editor?(conn, [])
    assert flash_messages_contain?(conn, "You are not authorized to view this page.")
    assert conn.halted
  end

  test "is_match_editor? halts when current_user has no match-editor role", %{conn: conn} do
    conn =
      conn
      |> assign(:current_user, %ClubHomepage.User{roles: "member player"})
      |> AuthByRole.is_match_editor?([])
    assert flash_messages_contain?(conn, "You are not authorized to view this page.")
    assert conn.halted
  end

  test "is_match_editor? continues when the current_user has the match-editor role", %{conn: conn} do
    conn =
      conn
      |> assign(:current_user, %ClubHomepage.User{roles: "member match-editor player"})
      |> AuthByRole.is_match_editor?([])
    refute conn.halted
  end



  test "is_member? halts when no current_user exists", %{conn: conn} do
    conn = AuthByRole.is_member?(conn, [])
    assert flash_messages_contain?(conn, "You are not authorized to view this page.")
    assert conn.halted
  end

  test "is_member? halts when current_user has no member role", %{conn: conn} do
    conn =
      conn
      |> assign(:current_user, %ClubHomepage.User{roles: "player"})
      |> AuthByRole.is_member?([])
    assert flash_messages_contain?(conn, "You are not authorized to view this page.")
    assert conn.halted
  end

  test "is_member? continues when the current_user has the member role", %{conn: conn} do
    conn =
      conn
      |> assign(:current_user, %ClubHomepage.User{roles: "member player"})
      |> AuthByRole.is_member?([])
    refute conn.halted
  end



  test "is_news_editor? halts when no current_user exists", %{conn: conn} do
    conn = AuthByRole.is_news_editor?(conn, [])
    assert flash_messages_contain?(conn, "You are not authorized to view this page.")
    assert conn.halted
  end

  test "is_news_editor? halts when current_user has no news-editor role", %{conn: conn} do
    conn =
      conn
      |> assign(:current_user, %ClubHomepage.User{roles: "member player"})
      |> AuthByRole.is_news_editor?([])
    assert flash_messages_contain?(conn, "You are not authorized to view this page.")
    assert conn.halted
  end

  test "is_news_editor? continues when the current_user has the news-editor role", %{conn: conn} do
    conn =
      conn
      |> assign(:current_user, %ClubHomepage.User{roles: "member news-editor player"})
      |> AuthByRole.is_news_editor?([])
    refute conn.halted
  end



  test "is_player? halts when no current_user exists", %{conn: conn} do
    conn = AuthByRole.is_player?(conn, [])
    assert flash_messages_contain?(conn, "You are not authorized to view this page.")
    assert conn.halted
  end

  test "is_player? halts when current_user has no player role", %{conn: conn} do
    conn =
      conn
      |> assign(:current_user, %ClubHomepage.User{roles: "member"})
      |> AuthByRole.is_player?([])
    assert flash_messages_contain?(conn, "You are not authorized to view this page.")
    assert conn.halted
  end

  test "is_player? continues when the current_user has the player role", %{conn: conn} do
    conn =
      conn
      |> assign(:current_user, %ClubHomepage.User{roles: "member player"})
      |> AuthByRole.is_player?([])
    refute conn.halted
  end



  test "is_team_editor? halts when no current_user exists", %{conn: conn} do
    conn = AuthByRole.is_team_editor?(conn, [])
    assert flash_messages_contain?(conn, "You are not authorized to view this page.")
    assert conn.halted
  end

  test "is_team_editor? halts when current_user has no team-editor role", %{conn: conn} do
    conn =
      conn
      |> assign(:current_user, %ClubHomepage.User{roles: "member player"})
      |> AuthByRole.is_team_editor?([])
    assert flash_messages_contain?(conn, "You are not authorized to view this page.")
    assert conn.halted
  end

  test "is_team_editor? continues when the current_user has the team-editor role", %{conn: conn} do
    conn =
      conn
      |> assign(:current_user, %ClubHomepage.User{roles: "member team-editor player"})
      |> AuthByRole.is_team_editor?([])
    refute conn.halted
  end



  test "is_text_page_editor? halts when no current_user exists", %{conn: conn} do
    conn = AuthByRole.is_text_page_editor?(conn, [])
    assert flash_messages_contain?(conn, "You are not authorized to view this page.")
    assert conn.halted
  end

  test "is_text_page_editor? halts when current_user has no text-page-editor role", %{conn: conn} do
    conn =
      conn
      |> assign(:current_user, %ClubHomepage.User{roles: "member player"})
      |> AuthByRole.is_text_page_editor?([])
    assert flash_messages_contain?(conn, "You are not authorized to view this page.")
    assert conn.halted
  end

  test "is_text_page_editor? continues when the current_user has the text-page-editor role", %{conn: conn} do
    conn =
      conn
      |> assign(:current_user, %ClubHomepage.User{roles: "member text-page-editor player"})
      |> AuthByRole.is_text_page_editor?([])
    refute conn.halted
  end



  test "is_user_editor? halts when no current_user exists", %{conn: conn} do
    conn = AuthByRole.is_user_editor?(conn, [])
    assert flash_messages_contain?(conn, "You are not authorized to view this page.")
    assert conn.halted
  end

  test "is_user_editor? halts when current_user has no user-editor role", %{conn: conn} do
    conn =
      conn
      |> assign(:current_user, %ClubHomepage.User{roles: "member player"})
      |> AuthByRole.is_user_editor?([])
    assert flash_messages_contain?(conn, "You are not authorized to view this page.")
    assert conn.halted
  end

  test "is_user_editor? continues when the current_user has the user-editor role", %{conn: conn} do
    conn =
      conn
      |> assign(:current_user, %ClubHomepage.User{roles: "member user-editor player"})
      |> AuthByRole.is_user_editor?([])
    refute conn.halted
  end



  test "has_role_from_list? halts when no current_user exists", %{conn: conn} do
    conn = AuthByRole.is_user_editor?(conn, [])
    assert flash_messages_contain?(conn, "You are not authorized to view this page.")
    assert conn.halted
  end

  test "has_role_from_list? halts when current_user has no user-editor role", %{conn: conn} do
    conn =
      conn
      |> assign(:current_user, %ClubHomepage.User{roles: "member player"})
      |> AuthByRole.has_role_from_list?(roles: ["trainer", "user-editor"])
      assert flash_messages_contain?(conn, "You are not authorized to view this page.")
    assert conn.halted
  end

  test "has_role_from_list? continues when the current_user has the user-editor role", %{conn: conn} do
    conn =
      conn
      |> assign(:current_user, %ClubHomepage.User{roles: "member user-editor player"})
      |> AuthByRole.has_role_from_list?(roles: ["trainer", "user-editor"])
    refute conn.halted
  end
end

defmodule ClubHomepage.UserControllerTest do
  use ClubHomepage.ConnCase
  use Bamboo.Test

  alias ClubHomepage.User

  import ClubHomepage.Factory

  @valid_attrs %{birthday: "17.04.1988", email: "mail@example.de", login: "my_login", name: "some name", password: "my name", password_confirmation: "my name"}
  @invalid_attrs %{}
  @invalid_attrs2 %{email: "invalid"}

  setup context do
    conn = build_conn()
    role = context[:login]
    cond do
      role == true -> assign_current_user(conn, insert(:user, roles: "member administrator"))
      is_binary(role) -> assign_current_user(conn, insert(:user, roles: "member #{role}"))
      true -> {:ok, conn: conn}
    end
  end

  @tag login: false
  test "requires user authentication on all actions", %{conn: conn} do
    user = insert(:user, token: "abc")
    Enum.each([
      get(conn, managed_user_path(conn, :index)),
      get(conn, managed_user_path(conn, :show, user)),
      get(conn, unregistered_user_path(conn, :new_unregistered)),
      post(conn, unregistered_user_path(conn, :create_unregistered), user: @valid_attrs),
      get(conn, managed_user_path(conn, :edit, user)),
      put(conn, managed_user_path(conn, :update, user), user: @valid_attrs)
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
      assert redirected_to(conn) =~ "/"
    end)
  end

  @tag login: "administrator"
  test "an administrator can access the index action", %{conn: conn, current_user: _current_user} do
    conn = get conn, managed_user_path(conn, :index)
    assert html_response(conn, 200) =~ "All Club Members"
  end

  @tag login: "user-editor"
  test "an user-editor can access the index action", %{conn: conn, current_user: _current_user} do
    conn = get conn, managed_user_path(conn, :index)
    assert html_response(conn, 200) =~ "All Club Members"
  end

  @tag login: "match-editor news-editor player text-page-editor trainer"
  test "all other roles can not access the index action", %{conn: conn, current_user: _current_user} do
    conn = get conn, managed_user_path(conn, :index)
    assert html_response(conn, 302)
    assert conn.halted
    assert redirected_to(conn) =~ "/"
  end

  @tag login: true
  test "try to lists all entries on index with login", %{conn: conn, current_user: _current_user} do
    user = insert(:user)
    unregistered_user = insert(:unregistered_user)
    conn = get conn, managed_user_path(conn, :index)
    assert html_response(conn, 200) =~ "All Club Members"
    assert html_response(conn, 200) =~ "<td>#{user.email}</td>"
    assert html_response(conn, 200) =~ "<td>#{unregistered_user.email}</td>"
  end

  @tag login: "user-editor"
  test "an user-editor can access the show action", %{conn: conn, current_user: _current_user} do
    user = insert(:user)
    conn = get conn, managed_user_path(conn, :show, user)
    assert html_response(conn, 200) =~ "<h2>#{user.login}</h2>"
  end

  @tag login: true
  test "renders form for new unregistered users with current_user logged in", %{conn: conn, current_user: _current_user} do
    conn = get conn, unregistered_user_path(conn, :new_unregistered)
    assert html_response(conn, 200) =~ "<h2>Create Club Member</h2>"
  end

  @tag login: true
  test "tries to create unregistered user with current_user is logged in", %{conn: conn, current_user: _current_user} do
    conn = post conn, unregistered_user_path(conn, :create_unregistered), user: %{}
    refute html_response(conn, 200) =~ "Secret wird benötigt"
    refute html_response(conn, 200) =~ "Login can&#39;t be blank"
    assert html_response(conn, 200) =~ "name can&#39;t be blank"
    assert html_response(conn, 200) =~ "email can&#39;t be blank"
    refute html_response(conn, 200) =~ "birthday can&#39;t be blank"
  end

  @tag login: true
  test "create unregistered user with current_user is logged in", %{conn: conn, current_user: _current_user} do
    user_attributes = %{email: "total-new-email@example.com", name: "total-new-name"}
    conn = post conn, unregistered_user_path(conn, :create_unregistered), user: user_attributes

    assert redirected_to(conn) == unregistered_user_path(conn, :new_unregistered)
    unregistered_user = Repo.get_by(User, email: user_attributes.email)
    assert unregistered_user.name == user_attributes.name
    assert unregistered_user.active == false
  end

  @tag login: false
  test "renders form for new users without secret parameter", %{conn: conn} do
    conn = get conn, user_path(conn, :new)
    assert html_response(conn, 200) =~ "Save"
  end

  @tag login: true
  test "does not render form for new users without secret parameter", %{conn: conn, current_user: _current_user} do
    conn = get conn, user_path(conn, :new)
    assert html_response(conn, 302)
    assert conn.halted
    assert redirected_to(conn) =~ "/"
  end

  @tag login: false
  test "renders form for new users with secret parameter", %{conn: conn} do
    conn = get conn, user_path(conn, :new, secret: "sdkljsdflksdjfisd")
    assert html_response(conn, 200) =~ "Save"
  end

  @tag login: true
  test "does not render form for new users with secret parameter", %{conn: conn, current_user: _current_user} do
    conn = get conn, user_path(conn, :new, secret: "sdkljsdflksdjfisd")
    assert html_response(conn, 302)
    assert conn.halted
    assert redirected_to(conn) =~ "/"
  end

  @tag login: false
  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, user_path(conn, :create), user: @valid_attrs
    assert html_response(conn, 200) =~ "Save"
    assert html_response(conn, 200) =~ "Secret can&#39;t be blank"

    secret = insert(:secret)
    new_valid_attrs = Map.put(@valid_attrs, :secret, secret.key)
    conn = post conn, user_path(conn, :create), user: new_valid_attrs

    assert redirected_to(conn) == page_path(conn, :index)
    user = Repo.get_by(User, login: @valid_attrs.login)
    assert user.active
    assert user.id == conn.assigns.current_user.id
  end

  @tag login: true
  test "does not create resource and redirect when data is valid", %{conn: conn, current_user: _current_user} do
    conn = post conn, user_path(conn, :create), user: @valid_attrs
    assert html_response(conn, 302)
    assert conn.halted
    assert redirected_to(conn) =~ "/"
  end

  @tag login: false
  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, user_path(conn, :create), user: @invalid_attrs
    assert html_response(conn, 200) =~ "Save"
    assert html_response(conn, 200) =~ "Secret can&#39;t be blank"
    assert html_response(conn, 200) =~ "login can&#39;t be blank"
    assert html_response(conn, 200) =~ "name can&#39;t be blank"
    assert html_response(conn, 200) =~ "email can&#39;t be blank"
    assert html_response(conn, 200) =~ "birthday can&#39;t be blank"
  end

  @tag login: true
  test "does not create resource and redirect when data is invalid", %{conn: conn, current_user: _current_user} do
    conn = post conn, user_path(conn, :create), user: @invalid_attrs
    assert html_response(conn, 302)
    assert conn.halted
    assert redirected_to(conn) =~ "/"
  end

  @tag login: true
  test "renders form for editing chosen resource", %{conn: conn} do
    user = insert(:user)
    conn = get conn, managed_user_path(conn, :edit, user)
    assert html_response(conn, 200) =~ "<h2>Edit Club Member</h2>"
  end

  @tag login: true
  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    user = insert(:user)
    conn = put conn, managed_user_path(conn, :update, user), user: @valid_attrs
    assert redirected_to(conn) == managed_user_path(conn, :index)
    assert Repo.get_by(User, email: @valid_attrs[:email])
  end

  @tag login: true
  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    user = insert(:user)
    conn = put conn, managed_user_path(conn, :update, user), user: @invalid_attrs2
    assert html_response(conn, 200) =~ "<h2>Edit Club Member</h2>"
  end

  # test "deletes chosen resource", %{conn: conn} do
  #   user = Repo.insert! %User{}
  #   conn = delete conn, user_path(conn, :delete, user)
  #   assert redirected_to(conn) == user_path(conn, :index)
  #   refute Repo.get(User, user.id)
  # end



  @tag login: true
  test "forgot password step 1 with an user is logged in", %{conn: conn} do
    conn = get conn, forgot_password_path(conn, :forgot_password_step_1)
    assert html_response(conn, 302)
    assert conn.halted
    assert redirected_to(conn) =~ "/"
  end

  @tag login: false
  test "forgot password step 1 without an user is logged in", %{conn: conn} do
    conn = get conn, forgot_password_path(conn, :forgot_password_step_1)
    assert html_response(conn, 200)
    assert html_response(conn, 200) =~ "<h2>Password forgotten?</h2>"
    assert html_response(conn, 200) =~ "<p>Type in your login or email to reset your password. Sometimes you"
  end



  @tag login: true
  test "forgot password step 2 with an user is logged in: type in an user login", %{conn: conn} do
    user = insert(:user)
    forgot_password_step_2_with_an_user_is_logged_in(conn, user.login)
  end

  @tag login: true
  test "forgot password step 2 with an user is logged in: type in an user email", %{conn: conn} do
    user = insert(:user)
    forgot_password_step_2_with_an_user_is_logged_in(conn, user.email)
  end

  defp forgot_password_step_2_with_an_user_is_logged_in(conn, login_or_email) do
    conn = post conn, forgot_password_path(conn, :forgot_password_step_2, %{"forgot_password" => %{"login_or_email" => login_or_email}})
    assert html_response(conn, 302)
    assert conn.halted
    assert redirected_to(conn) =~ "/"
  end

  @tag login: false
  test "forgot password step 2 without an user is logged in: type in a user login", %{conn: conn} do
    user = insert(:user)
    forgot_password_step_2_without_an_user_is_logged_in(conn, user.login)
  end

  @tag login: false
  test "forgot password step 2 without an user is logged in: type in a wrong user login", %{conn: conn} do
    forgot_password_step_2_without_an_user_is_logged_in(conn, "aaa")
  end

  @tag login: false
  test "forgot password step 2 without an user is logged in: type in a user email", %{conn: conn} do
    user = insert(:user)
    forgot_password_step_2_without_an_user_is_logged_in(conn, user.email)
  end

  @tag login: false
  test "forgot password step 2 without an user is logged in: type in a wrong user email", %{conn: conn} do
    forgot_password_step_2_without_an_user_is_logged_in(conn, "bbb")
  end

  defp forgot_password_step_2_without_an_user_is_logged_in(conn, login_or_email) do
    conn = post conn, forgot_password_path(conn, :forgot_password_step_2, %{"forgot_password" => %{"login_or_email" => login_or_email}})
    assert html_response(conn, 200)
    assert html_response(conn, 200) =~ "<h2>Password forgotten?</h2>"
    assert html_response(conn, 200) =~ "<p>We sent you an email with a link in it. Click this"
    user = Repo.get_by(User, login: login_or_email) || Repo.get_by(User, email: login_or_email)
    if user do
      assert_delivered_email ClubHomepage.Email.forgot_password_email(conn, user)
    end
  end



  @tag login: true
  test "change password with an user is logged in", %{conn: conn} do
    user = insert(:user, token: "abc")
    conn = get conn, change_password_path(conn, :change_password, user.id, user.token)
    assert html_response(conn, 302)
    assert conn.halted
    assert redirected_to(conn) =~ "/"
  end

  @tag login: false
  test "change password without an user is logged in: unknown user id given", %{conn: conn} do
    conn = get conn, change_password_path(conn, :change_password, 0, "unknown")
    assert html_response(conn, 302)
    assert redirected_to(conn) =~ forgot_password_path(conn, :forgot_password_step_1)
    assert flash_messages_contain?(conn, "The Account for this login/email does not exist.")
  end

  @tag login: false
  test "change password without an user is logged in: user id with wrong token given", %{conn: conn} do
    user = insert(:user)
    conn = get conn, change_password_path(conn, :change_password, user.id, "wrong")
    assert html_response(conn, 302)
    assert redirected_to(conn) =~ forgot_password_path(conn, :forgot_password_step_1)
    assert flash_messages_contain?(conn, "The account does not exist or the reset link is not valid anymore.")
  end

  @tag login: false
  test "change password without an user is logged in: user id and timed out token given", %{conn: conn} do
    user = insert(:user, token: "abc", token_set_at: Timex.add(Timex.now, Timex.Duration.from_days(-3)))
    conn = get conn, change_password_path(conn, :change_password, user.id, user.token)
    assert html_response(conn, 302)
    assert redirected_to(conn) =~ forgot_password_path(conn, :forgot_password_step_1)
    assert flash_messages_contain?(conn, "Your password change request timed out.")
  end

  @tag login: false
  test "change password without an user is logged in: user id and token given", %{conn: conn} do
    user = insert(:user, token: "abc", token_set_at: Timex.now)
    conn = get conn, change_password_path(conn, :change_password, user.id, user.token)
    assert html_response(conn, 200)
    assert html_response(conn, 200) =~ "<h2>Reset Password</h2>"
  end



  @tag login: true
  test "reset password with an user is logged in", %{conn: conn} do
    user = insert(:user, token: "abc", token_set_at: Timex.now)
    conn = put conn, reset_password_path(conn, :reset_password, id: user.id, token: user.token, password: "new-password", password_confirmation: "new-password")
    assert html_response(conn, 302)
    assert conn.halted
    assert redirected_to(conn) =~ "/"
  end

  defp assign_current_user(conn, current_user) do
    conn = assign(conn, :current_user, current_user)
    {:ok, conn: conn, current_user: current_user}
  end
end

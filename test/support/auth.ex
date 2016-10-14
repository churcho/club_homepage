defmodule ClubHomepage.Test.Support.Auth do
  import ClubHomepage.Factory

  def login(conn) do
    user = insert(:user)
    Plug.Conn.assign(conn, :current_user, user)
  end
end

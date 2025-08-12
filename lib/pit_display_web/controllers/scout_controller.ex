defmodule PitDisplayWeb.ScoutController do
  use PitDisplayWeb, :controller

  def home(conn, _params) do
    conn
    |> render(:home)
  end
end

defmodule PitDisplayWeb.ScoutController do
  use PitDisplayWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end

defmodule PitDisplayWeb.ClipController do
  use PitDisplayWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end

defmodule PitDisplayWeb.StatsController do
  use PitDisplayWeb, :controller

  def home(conn, _params) do
    conn
    |> render(:home)
  end

  def events(conn, _params) do
    conn
    |> render(:events)
  end

  def records(conn, _params) do
    conn
    |> render(:records)
  end
end

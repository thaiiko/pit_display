defmodule PitDisplayWeb.PitController do
  use PitDisplayWeb, :controller

  def home(conn, params) do
    team = params["team"]
    eventcode = params["eventcode"]

    if team && eventcode do
      redirect(conn, to: ~p"/pit/#{team}/#{eventcode}")
    else
      render(conn, :home)
    end
  end
end

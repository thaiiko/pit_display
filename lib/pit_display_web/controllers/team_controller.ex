defmodule PitDisplayWeb.TeamController do
  alias PitDisplay.Ftc
  use PitDisplayWeb, :controller

  def show(conn, %{"id" => id}) do
    # Fetch both team data and events data
    team_result = Ftc.fetch_team(id)
    events_result = Ftc.fetch_events(id)
    IO.inspect(events_result)
    IO.inspect(conn)

    case {team_result, events_result} do
      {{:ok, team}, {:ok, events}} ->
        team_website =
          if team.website && team.website != "" do
            if String.contains?(team.website, "http") do
              team.website
            else
              "https://#{team.website}"
            end
          end

        IO.inspect(team.state_prov)

        conn
        |> assign(:team, team)
        |> assign(:events, events)
        |> assign(:team_website, team_website)
        |> render(:show)

      {{:ok, team}, {:error, _events_error}} ->
        # Team found but events failed - still show team
        conn
        |> assign(:team, team)
        |> assign(:events, [])
        |> put_flash(:warning, "Team found but could not load events data")
        |> render(:show)

      {{:error, reason}, _} ->
        conn
        |> put_flash(:error, "Could not fetch team #{id}, HTTP Error Code: #{inspect(reason)}")
        |> redirect(to: ~p"/stats/teams")
    end
  end
end

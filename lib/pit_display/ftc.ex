defmodule PitDisplay.Ftc do
  alias PitDisplay.FtcApi.Client

  @doc """
  Fetches all teams and processes their data for display.
  """
  def fetch_all_teams do
    case Client.get_all_teams() do
      {:ok, %{"teams" => teams}} when is_list(teams) ->
        # Process teams data
        formatted_teams =
          Enum.map(teams, fn team ->
            %{
              team_number: team["teamNumber"],
              team_name: team["nameShort"] || team["nameFull"] || "Unknown",
              city: team["city"],
              state_prov: team["stateProv"],
              country: team["country"]
            }
          end)

        {:ok, formatted_teams}

      {:ok, _other_data} ->
        {:error, :unexpected_api_response}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Fetches teams by page and processes their data for display.
  """
  def fetch_teams_by_page(page) do
    case Client.get_team_by_page(page) do
      {:ok, %{"teams" => teams, "pageTotal" => total_pages}} when is_list(teams) ->
        # Process teams data
        formatted_teams =
          Enum.map(teams, fn team ->
            %{
              team_number: team["teamNumber"],
              team_name: team["nameShort"] || team["nameFull"] || "Unknown",
              city: team["city"],
              state_prov: team["stateProv"],
              country: team["country"]
            }
          end)

        {:ok, formatted_teams, total_pages}

      {:ok, _other_data} ->
        {:error, :unexpected_api_response}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Fetches data for a specific team by team number.
  """
  def fetch_team(team_number) do
    case Client.get_team_by_pin(team_number) do
      {:ok, %{"teams" => [team]}} ->
        formatted_team = %{
          team_number: team["teamNumber"],
          team_name: team["nameShort"] || team["nameFull"] || "Unknown",
          school: team["schoolName"],
          robot_name: team["robotName"],
          city: team["city"],
          state_prov: team["stateProv"],
          country: team["country"],
          rookie_year: team["rookieYear"],
          website: team["website"]
        }

        {:ok, formatted_team}

      {:ok, _other_data} ->
        {:error, :team_not_found}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Fetches events for a specific team by team number.
  """
  def fetch_events(team_number) do
    case Client.get_matches_by_pin(team_number) do
      {:ok, %{"events" => events}} when is_list(events) ->
        formatted_events =
          Enum.map(events, fn event ->
            %{
              code: event["code"],
              name: event["name"],
              remote: event["remote"],
              hybrid: event["hybrid"],
              field_count: event["fieldCount"],
              published: event["published"],
              type: event["type"],
              type_name: event["typeName"],
              region_code: event["regionCode"],
              venue: event["venue"],
              address: event["address"],
              city: event["city"],
              state_prov: event["stateprov"],
              country: event["country"],
              website: event["website"],
              live_stream_url: event["liveStreamUrl"],
              timezone: event["timezone"],
              date_start: event["dateStart"],
              date_end: event["dateEnd"]
            }
          end)

        {:ok, formatted_events}

      {:ok, _other_data} ->
        {:error, :unexpected_api_response}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def fetch_scores_by_event(event_code, tournament_level) do
    case Client.get_score_by_event(event_code, tournament_level) do
      {:ok, %{"matchScores" => match_scores}} when is_list(match_scores) ->
        # Process all matches and flatten their alliances
        formatted_alliances =
          match_scores
          |> Enum.flat_map(fn match ->
            alliances = match["alliances"] || []

            Enum.map(alliances, fn alliance ->
              %{
                alliance: alliance["alliance"],
                robot_1_auto: alliance["robot1Auto"],
                robot_2_auto: alliance["robot2Auto"],
                auto_sample_net: alliance["autoSampleNet"],
                auto_sample_low: alliance["autoSampleLow"],
                auto_sample_high: alliance["autoSampleHigh"],
                auto_specimen_low: alliance["autoSpecimenLow"],
                auto_specimen_high: alliance["autoSpecimenHigh"],
                teleop_sample_net: alliance["teleopSampleNet"],
                teleop_sample_low: alliance["teleopSampleLow"],
                teleop_sample_high: alliance["teleopSampleHigh"],
                teleop_specimen_low: alliance["teleopSpecimenLow"],
                teleop_specimen_high: alliance["teleopSpecimenHigh"],
                robot_1_teleop: alliance["robot1Teleop"],
                robot_2_teleop: alliance["robot2Teleop"],
                minor_fouls: alliance["minorFouls"],
                major_fouls: alliance["majorFouls"],
                auto_sample_points: alliance["autoSamplePoints"],
                auto_specimen_points: alliance["autoSpecimenPoints"],
                teleop_sample_points: alliance["teleopSamplePoints"],
                teleop_specimen_points: alliance["teleopSpecimenPoints"],
                teleop_park_points: alliance["teleopParkPoints"],
                teleop_ascent_points: alliance["teleopAscentPoints"],
                auto_points: alliance["autoPoints"],
                teleop_points: alliance["teleopPoints"],
                end_game_points: alliance["endGamePoints"],
                foul_points_committed: alliance["foulPointsCommitted"],
                pre_foul_total: alliance["preFoulTotal"],
                total_points: alliance["totalPoints"],
                match_level: match["matchLevel"],
                match_series: match["matchSeries"],
                match_number: match["matchNumber"]
              }
            end)
          end)

        {:ok, %{"formatted_alliances" => formatted_alliances}}

      {:ok, _malformed_data} ->
        {:error, :unexpected_api_response}

      {:error, reason} ->
        {:error, reason}
    end
  end

  # Alias for the controller
  def fetch_teams, do: fetch_all_teams()
end

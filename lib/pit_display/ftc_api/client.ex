defmodule PitDisplay.FtcApi.Client do
  HTTPoison.start()

  defp get_api_key do
    Application.get_env(:pit_display, :ftc_api_key) ||
      System.get_env("FTC_API_KEY") ||
      raise "FTC API key not configured. Set FTC_API_KEY environment variable or configure :ftc_api_key in config."
  end

  defp get_base_url do
    Application.get_env(:pit_display, :ftc_api_base_url) ||
      "https://ftc-api.firstinspires.org/v2.0/2024"
  end

  @doc """
    Fetches All of the teams, and their names
  """
  def get_all_teams do
    url = "#{get_base_url()}/teams"
    # API key should be base64 encoded if required by FTC API
    auth_header = {"Authorization", "Basic #{get_api_key()}"}

    case HTTPoison.get(url, [{"Accept", "application/json"}, auth_header]) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, data} ->
            {:ok, data}

          {:error, _} ->
            {:error, :invalid_json_response}
        end

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        IO.warn("Error Code: #{status_code}, Body: #{body}")
        {:error, {:http_error, status_code}}

      {:error, %HTTPoison.Error{reason: reason}} ->
        # Handle connection or request errors
        IO.inspect("FTC Robotics API connection error: #{inspect(reason)}")
        {:error, {:connection_error, reason}}
    end
  end

  def get_team_by_page(page) do
    url = "#{get_base_url()}/teams?page=#{page}"
    # API key should be base64 encoded if required by FTC API
    auth_header = {"Authorization", "Basic #{get_api_key()}"}

    case HTTPoison.get(url, [{"Accept", "application/json"}, auth_header]) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, data} ->
            {:ok, data}

          {:error, _} ->
            {:error, :invalid_json_response}
        end

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        IO.warn("Error Code: #{status_code}, Body: #{body}")
        {:error, {:http_error, status_code}}

      {:error, %HTTPoison.Error{reason: reason}} ->
        # Handle connection or request errors
        IO.inspect("FTC Robotics API connection error: #{inspect(reason)}")
        {:error, {:connection_error, reason}}
    end
  end

  @doc """
    Fetches All the teams concurrently
  """
  @spec get_all_teams_recursively(max_concurrency :: integer()) ::
          {:ok, list(map())}
          | {:error, {:initial_fetch_failed}}
          | {:error, {:task_failure, any(), list(map())}}
  def get_all_teams_recursively(max_concurrency \\ 10) do
    case get_team_by_page(1) do
      {:ok, %{"teams" => first_page_team, "pageTotal" => total_pages}} ->
        IO.puts("Fetched First Page")
        pages_to_fetch = if total_pages > 1, do: Enum.to_list(2..total_pages), else: []

        concurrent_results =
          pages_to_fetch
          |> Task.async_stream(
            &PitDisplay.FtcApi.Client.get_team_by_page/1,
            max_concurrency: max_concurrency,
            ordered: true,
            # Sixty Second timer
            timeout: 60_000
          )
          |> Enum.reduce({:ok, []}, fn
            {:ok, {:ok, %{"teams" => new_teams}}}, {:ok, acc_teams} ->
              # Accumulate teams
              {:ok, acc_teams ++ new_teams}

            # API client returned an error for a page
            {:ok, {:error, reason}}, {:ok, acc_teams} ->
              IO.warn(
                "Individual page fetch error: #{inspect(reason)}. Skipping teams from this page."
              )

              # Continue with accumulated teams, skipping this page
              {:ok, acc_teams}

            # Task itself failed (e.g., timeout)
            {:error, task_error_reason}, {:ok, acc_teams} ->
              IO.warn(
                "Task failure for a page: #{inspect(task_error_reason)}. Stopping concurrent fetch."
              )

              # Stop and return error
              {:error, {:task_failure, task_error_reason, acc_teams}}

            # Catch-all for unexpected states
            error, _ ->
              # Pass through existing error or propagate new one
              error
          end)

        case concurrent_results do
          {:ok, remaining_teams} ->
            {:ok, first_page_team ++ remaining_teams}

          {:error, _} = error ->
            error
        end

      {:error, reason} ->
        {:error, {:initial_fetch_failed, reason}}
    end
  end

  @doc """
    Fetches Data about teams
  """
  def get_team_by_pin(team_number) do
    url = "#{get_base_url()}/teams?teamNumber=#{team_number}"
    # API key should be base64 encoded if required by FTC API
    auth_header = {"Authorization", "Basic #{get_api_key()}"}
    IO.inspect(url)

    case HTTPoison.get(url, [{"Accept", "application/json"}, auth_header]) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, data} ->
            {:ok, data}

          {:error, _} ->
            {:error, :invalid_json_response}
        end

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        IO.warn("Error Code: #{status_code}, Body: #{body}")
        {:error, {:http_error, status_code}}

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect("FTC Robotics API connection error: #{inspect(reason)}")
        {:error, {:connection_error, reason}}
    end
  end

  @doc """
    Fetches events for a specific team by team number
  """
  def get_matches_by_pin(team_number) do
    url = "#{get_base_url()}/events?teamNumber=#{team_number}"
    # API key should be base64 encoded if required by FTC API
    auth_header = {"Authorization", "Basic #{get_api_key()}"}
    IO.inspect(url)

    case HTTPoison.get(url, [{"Accept", "application/json"}, auth_header]) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, data} ->
            {:ok, data}

          {:error, _} ->
            {:error, :invalid_json_response}
        end

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        IO.warn("Error Code: #{status_code}, Body: #{body}")
        {:error, {:http_error, status_code}}

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect("FTC Robotics API connection error: #{inspect(reason)}")
        {:error, {:connection_error, reason}}
    end
  end

  # RANKING

  @doc """
    All Event Scores
  """
  def get_score_by_event(event_code, tournament_level) do
    url = "#{get_base_url()}/scores/#{event_code}/#{tournament_level}"
    # API key should be base64 encoded if required by FTC API
    auth_header = {"Authorization", "Basic #{get_api_key()}"}

    case HTTPoison.get(url, [{"Accept", "application/json"}, auth_header]) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, data} ->
            {:ok, data}

          {:error, _} ->
            {:error, :invalid_json_response}
        end

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        IO.warn("Error Code #{status_code}, Body: #{body}")
        {:error, {:http_error, status_code}}

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.warn("FTC Robotics API connection error: #{inspect(reason)}")
        {:error, {:connection_error, reason}}
    end
  end
end

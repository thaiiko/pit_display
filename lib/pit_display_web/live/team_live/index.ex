defmodule PitDisplayWeb.TeamLive.Index do
  use PitDisplayWeb, :live_view
  alias PitDisplay.FtcApi.Client

  def mount(_params, _session, socket) do
    # Corrected: Expect a single 'team' map as the argument
    socket = stream_configure(socket, :teams, dom_id: fn team -> "#{team.team_number}" end)

    case Client.get_team_by_page(1) do
      {:ok, %{"teams" => teams, "pageTotal" => total_pages}} ->
        {:ok,
         socket
         |> stream(:teams, format_teams(teams), dom_id: &"teams-#{&1.team_number}")
         |> assign(:current_page, 1)
         |> assign(:total_pages, total_pages)
         |> assign(:loading, false)}

      {:error, reason} ->
        {:ok,
         socket
         |> stream(:teams, [], dom_id: &"teams-#{&1.team_number}")
         |> assign(:current_page, 1)
         |> assign(:total_pages, 0)
         |> assign(:loading, false)
         |> put_flash(:error, "Error fetching teams: #{inspect(reason)}")}
    end
  end

  def handle_event("load_more", _, socket) do
    next_page = socket.assigns.current_page + 1

    if next_page <= socket.assigns.total_pages do
      send(self(), {:load_page, next_page})
    end

    {:noreply, socket}
  end

  def handle_info({:load_page, page_number}, socket) do
    case Client.get_team_by_page(page_number) do
      {:ok, %{"teams" => teams, "pageTotal" => total_pages}} ->
        {:noreply,
         socket
         |> stream(:teams, format_teams(teams), dom_id: &"teams=#{&1.team_number}")
         |> assign(:current_page, page_number)
         |> assign(:total_pages, total_pages)
         |> assign(:loading, false)}

      {:error, reason} ->
        {:noreply,
         socket
         |> assign(:loading, false)
         |> put_flash(:error, "Error loading page #{page_number}: #{inspect(reason)}")}
    end
  end

  defp format_teams(teams) do
    Enum.map(teams, fn team ->
      %{
        team_number: team["teamNumber"],
        team_name: team["nameShort"] || team["nameFull"] || "Unknown",
        city: team["city"],
        state_prov: team["stateProv"],
        country: team["country"]
      }
    end)
  end
end

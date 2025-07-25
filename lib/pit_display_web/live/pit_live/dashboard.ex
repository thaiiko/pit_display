defmodule PitDisplayWeb.PitLive.Dashboard do
  use PitDisplayWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Process.send_after(self(), :fetch_new_data, 1000)

    {:ok, assign(socket, :alliances, [])}
  end

  @impl true
  def handle_info(:fetch_new_data, socket) do
    # Simulate new data coming in
    new_alliance = %{
      "red" => [%{"team_number" => 123, "team_name" => "Team A"}],
      "blue" => [%{"team_number" => 456, "team_name" => "Team B"}]
    }

    alliances = socket.assigns.alliances ++ [new_alliance]

    Process.send_after(self(), :fetch_new_data, 1000)

    {:noreply, assign(socket, :alliances, alliances)}
  end
end

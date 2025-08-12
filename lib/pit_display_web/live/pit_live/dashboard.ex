defmodule PitDisplayWeb.PitLive.Dashboard do
  alias PitDisplay.Ftc
  use PitDisplayWeb, :live_view

  def mount(%{"team_id" => _team, "event_id" => event}, _session, socket) do
    if connected?(socket),
      do: Process.send(self(), {:fetch_new_data, %{event: event}}, [])

    {:ok, assign(socket, :alliances, [])}
  end

  def handle_info({:fetch_new_data, %{event: event}}, socket) do
    case Ftc.fetch_scores_by_event(event, "qual") do
      {:ok, %{"formatted_alliances" => alliances}} ->
        {:noreply, assign(socket, :alliances, alliances)}

      {:error, reason} ->
        # Handle the error case, maybe log it or show a message to the user
        IO.inspect(reason)
        {:noreply, socket}
    end
  end
end

defmodule PitDisplayWeb.PageController do
  use PitDisplayWeb, :controller

  def home(conn, _params) do
    valid_consoles = PitDisplayWeb.Plugs.SetConsole.valid_consoles()
    conn = assign(conn, :valid_consoles, valid_consoles)
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end
end

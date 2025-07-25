defmodule PitDisplayWeb.Plugs.SetConsole do
  import Plug.Conn
  def init(opts), do: opts

  @valid_consoles ["pc", "xbox", "playstation", "nintendo"]
  def valid_consoles, do: @valid_consoles

  def call(%Plug.Conn{:params => %{"console" => console}} = conn, _opts)
      when console in @valid_consoles do
    conn
    |> assign(:console, console)
    |> put_resp_cookie("console", console, max_age: 60 * 60 * 24 * 30)
  end

  def call(%Plug.Conn{:cookies => %{"console" => console}} = conn, _opts)
      when console in @valid_consoles do
    conn
    |> assign(:console, console)
  end

  def call(%Plug.Conn{} = conn, default_console) do
    conn
    |> assign(:console, default_console)
  end
end

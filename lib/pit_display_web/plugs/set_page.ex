defmodule PitDisplayWeb.Plugs.SetPage do
  import Plug.Conn
  def init(opts), do: opts

  @valid_consoles [1..103]
  def valid_consoles, do: @valid_consoles

  def call(%Plug.Conn{:params => %{"page" => page}} = conn, _opts) when page in @valid_consoles do
    conn
    |> assign(:page, page)
    |> put_resp_cookie("page", page, max_age: 60 * 60 * 24 * 30)
  end

  def call(%Plug.Conn{:cookies => %{"page" => page}} = conn, _opts)
      when page in @valid_consoles do
    conn
    |> assign(:page, page)
  end

  def call(%Plug.Conn{} = conn, default_page) do
    conn
    |> assign(:page, default_page)
  end
end

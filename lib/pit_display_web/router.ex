defmodule PitDisplayWeb.Router do
  use PitDisplayWeb, :router

  alias PitDisplayWeb.Plugs

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {PitDisplayWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Plugs.SetConsole, "pc"
    plug Plugs.SetPage, 1
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/" do
    pipe_through :browser

    get "/", PitDisplayWeb.PageController, :home
    get "/teams/:id", PitDisplayWeb.TeamController, :show

    # LiveView routes
    live "/teams", PitDisplayWeb.TeamLive.Index, :index
    get "/clips", PitDisplayWeb.ClipController, :home

    # this provides all the routes
    # resources "products", ProductController, only: [:index, :show]
  end

  scope "/stats" do
    pipe_through :browser

    get "/", PitDisplayWeb.StatsController, :home
    get "/teams/:id", PitDisplayWeb.TeamController, :show
    get "/events", PitDisplayWeb.StatsController, :events
    get "/records", PitDisplayWeb.StatsController, :records

    live "/teams", PitDisplayWeb.TeamLive.Index, :index
  end

  scope "/pit" do
    get "/", PitDisplayWeb.PitController, :home
    live "/:team_id/:event_id", PitDisplayWeb.PitLive.Dashboard, :dashboard
  end

  scope "/scout" do
    get "/", PitDisplayWeb.ScoutController, :home
  end

  # Other scopes may use custom stacks.
  scope "/api" do
    pipe_through :api
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:pit_display, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: PitDisplayWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end

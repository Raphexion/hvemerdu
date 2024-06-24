defmodule HvemerduWeb.Router do
  use HvemerduWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {HvemerduWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :auth do
    plug HvemerduWeb.Plugs.Auth
  end

  pipeline :jwt_auth do
    plug HvemerduWeb.Plugs.JwtAuth
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", HvemerduWeb do
    pipe_through :browser

    live "/", ChallengeLive
  end

  scope "/v1", HvemerduWeb do
    pipe_through [:api, :jwt_auth]

    post "/verify", VerifyController, :ack
  end

  # Other scopes may use custom stacks.
  # scope "/api", HvemerduWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard in development
  if Application.compile_env(:hvemerdu, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: HvemerduWeb.Telemetry
    end
  end
end

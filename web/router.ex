defmodule StubOnWeb.Router do
  use StubOnWeb.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", StubOnWeb do
    pipe_through :browser # Use the default browser stack

    get "/", StubUrlController, :new
    resources "/stub_urls", StubUrlController, only: [:new, :create, :update]
    get "/edit/*path_fragments", StubUrlController, :edit
  end


  scope "/", StubOnWeb do
    # TODO: Figure out one liner to add below routes
    get "/*path_fragments", StubUrlController, :show
    post "/*path_fragments", StubUrlController, :show
    put "/*path_fragments", StubUrlController, :show
    delete "/*path_fragments", StubUrlController, :show
    head "/*path_fragments", StubUrlController, :show
    patch "/*path_fragments", StubUrlController, :show
    options "/*path_fragments", StubUrlController, :show
  end

  # Other scopes may use custom stacks.
  # scope "/api", StubOnWeb do
  #   pipe_through :api
  # end
end

defmodule StubOnWeb.PageController do
  use StubOnWeb.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end

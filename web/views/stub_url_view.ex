defmodule StubOnWeb.StubUrlView do
  use StubOnWeb.Web, :view

  alias StubOnWeb.StubUrl

  def get_stub_url_url(conn, action, stub_url) do
    stub_url_url(conn, action, StubUrl.path_fragments(stub_url))
  end

  def max_allowed_delay() do
    Application.get_env(:stub_on_web, :max_allowed_delay)
  end
end

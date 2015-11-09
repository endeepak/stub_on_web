defmodule StubOnWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :stub_on_web

  socket "/socket", StubOnWeb.UserSocket

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phoenix.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/", from: :stub_on_web, gzip: false,
    only: ~w(css fonts images js favicon.ico robots.txt)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Logger

  defp copy_req_body(conn, _) do
    {:ok, body, _} = Plug.Conn.read_body(conn, length: 1_000_000_000)
    Plug.Conn.put_private(conn, :raw_request_body, body)
  end
  
  plug :copy_req_body

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison

  plug Plug.MethodOverride
  plug Plug.Head

  plug Plug.Session,
    store: :cookie,
    key: "_stub_on_web_key",
    signing_salt: "4hbFnh4x"

  plug StubOnWeb.Router
end

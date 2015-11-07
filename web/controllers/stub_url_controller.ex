defmodule StubOnWeb.StubUrlController do
  use StubOnWeb.Web, :controller

  alias StubOnWeb.StubUrl
  alias StubOnWeb.StubUrlCall

  plug :scrub_params, "stub_url" when action in [:create, :update]

  def new(conn, params) do
    random_path = Ecto.UUID.generate |> String.split("-") |> List.last
    default_attrs = %{path: random_path, response_status: 200}
    changeset = StubUrl.changeset(%StubUrl{}, default_attrs)
    previous_stub_url = if params["previous_path"], do: %StubUrl{path: params["previous_path"]}, else: nil
    render(conn, "new.html", changeset: changeset, previous_stub_url: previous_stub_url)
  end

  def create(conn, %{"stub_url" => stub_url_params}) do
    changeset = StubUrl.changeset(%StubUrl{}, stub_url_params)

    case Repo.insert(changeset) do
      {:ok, stub_url} ->
        conn
        |> redirect(to: stub_url_path(conn, :new, previous_path: stub_url.path))
      {:error, changeset} ->
        conn 
        |> put_status(422)
        |> render("new.html", changeset: changeset, previous_stub_url: nil)
    end
  end

  def get_stub_url!(path_fragments) do
    path = path_fragments |> Enum.join("/")
    Repo.one!(from s in StubUrl, where: s.path == ^path or s.path == ^(path <> "/"))
  end

  def show(conn, %{"path_fragments" => path_fragments}) do
    stub_url = get_stub_url!(path_fragments)
    response_headers = stub_url.response_headers || []
    conn = Enum.reduce(response_headers, conn, fn(header, conn) -> 
      put_resp_header(conn, String.downcase(header.name), header.value) 
    end)
    _capture_call(conn, stub_url)
    send_resp(conn, stub_url.response_status, stub_url.response_body || "")
  end

  def _capture_call(conn, stub_url) do
    request_headers = Enum.map(conn.req_headers, fn {name, value} -> %{name: name, value: value} end)
    {:ok, request_body, conn} = Plug.Conn.read_body(conn, length: 1_000_000)
    request_data = %{url: _get_url_from_conn(conn), body: request_body, method: conn.method, headers: request_headers}
    response_headers = Enum.map(stub_url.response_headers, fn header -> %{name: header.name, value: header.value} end)
    response_data = %{status: stub_url.response_status, headers: response_headers, body: stub_url.response_body}
    call_data = %{request: request_data, response: response_data, stub_url_id: stub_url.id}
    changeset = StubUrlCall.changeset(%StubUrlCall{}, call_data)
    Repo.insert!(changeset)
  end

  def _get_url_from_conn(conn) do
    if(conn.query_string != nil and conn.query_string != "") do conn.request_path <> "?" <> conn.query_string else conn.request_path end
  end

  def show_calls(conn, %{"path_fragments" => path_fragments}) do
    stub_url = get_stub_url!(path_fragments) |> Repo.preload(calls: from(c in StubUrlCall, order_by: [desc: c.inserted_at]))
    render(conn, "calls.html", stub_url: stub_url)
  end

  def edit(conn, %{"path_fragments" => path_fragments}) do
    stub_url = get_stub_url!(path_fragments)
    changeset = StubUrl.changeset(stub_url)
    render(conn, "edit.html", stub_url: stub_url, changeset: changeset)
  end

  def update(conn, %{"id" => id, "stub_url" => stub_url_params}) do
    stub_url = Repo.get!(StubUrl, id)
    stub_url_params = Map.put(stub_url_params, "response_headers", stub_url_params["response_headers"] || [])
    changeset = StubUrl.changeset(stub_url, stub_url_params)

    case Repo.update(changeset) do
      {:ok, stub_url} ->
        conn
        |> redirect(to: stub_url_path(conn, :new, previous_path: stub_url.path))
      {:error, changeset} ->
        conn 
        |> put_status(422)
        |> render("edit.html", stub_url: stub_url, changeset: changeset)
    end
  end
end

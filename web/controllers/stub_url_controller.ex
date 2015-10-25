defmodule StubOnWeb.StubUrlController do
  use StubOnWeb.Web, :controller

  alias StubOnWeb.StubUrl
  alias StubOnWeb.HttpHeader

  plug :scrub_params, "stub_url" when action in [:create, :update]

  def new(conn, _params) do
    random_path = Ecto.UUID.generate |> String.split("-") |> List.last
    default_attrs = %{path: random_path, response_status: 200}
    changeset = StubUrl.changeset(%StubUrl{}, default_attrs)
    render(conn, "new.html", changeset: changeset, previous_stub_url: get_flash(conn, :previous_stub_url))
  end

  def create(conn, %{"stub_url" => stub_url_params}) do
    changeset = StubUrl.changeset(%StubUrl{}, stub_url_params)

    case Repo.insert(changeset) do
      {:ok, stub_url} ->
        conn
        |> put_flash(:previous_stub_url, stub_url)
        |> redirect(to: stub_url_path(conn, :new))
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

    send_resp(conn, stub_url.response_status, stub_url.response_body || "")
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
        |> put_flash(:previous_stub_url, stub_url)
        |> redirect(to: stub_url_path(conn, :new))
      {:error, changeset} ->
        conn 
        |> put_status(422)
        |> render("edit.html", stub_url: stub_url, changeset: changeset)
    end
  end
end

defmodule StubOnWeb.StubUrlController do
  use StubOnWeb.Web, :controller

  alias StubOnWeb.StubUrl
  alias StubOnWeb.StubUrlCall

  plug :scrub_params, "stub_url" when action in [:create, :update]

  def new(conn, params) do
    changeset = StubUrl.new_changeset(params["template"])
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

  def show(conn, %{"path_fragments" => path_fragments}) do
    stub_url = StubUrl.get_by_path_fragments!(path_fragments)
    response_headers = stub_url.response_headers || []
    conn = Enum.reduce(response_headers, conn, fn(header, conn) -> 
      put_resp_header(conn, String.downcase(header.name), header.value) 
    end)
    StubUrl.notify_call(stub_url, conn)
    send_resp(conn, stub_url.response_status, stub_url.response_body || "")
  end

  def show_calls(conn, %{"path_fragments" => path_fragments}) do
    max_stub_url_calls = Application.get_env(:stub_on_web, :max_stub_url_calls)
    stub_url = StubUrl.get_by_path_fragments!(path_fragments) 
              |> Repo.preload(calls: from(c in StubUrlCall, limit: ^max_stub_url_calls, order_by: [desc: c.inserted_at]))
    render(conn, "calls.html", stub_url: stub_url, max_stub_url_calls: max_stub_url_calls)
  end

  def edit(conn, %{"path_fragments" => path_fragments}) do
    stub_url = StubUrl.get_by_path_fragments!(path_fragments)
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
        |> put_flash(:success, 'Updated successfully')
        |> redirect(to: stub_url_path(conn, :edit, StubUrl.path_fragments(stub_url)))
      {:error, changeset} ->
        conn 
        |> put_status(422)
        |> render("edit.html", stub_url: stub_url, changeset: changeset)
    end
  end
end

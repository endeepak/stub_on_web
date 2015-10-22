defmodule StubOnWeb.StubUrlController do
  use StubOnWeb.Web, :controller

  alias StubOnWeb.StubUrl

  plug :scrub_params, "stub_url" when action in [:create, :update]

  def index(conn, _params) do
    stub_urls = Repo.all(StubUrl)
    render(conn, "index.html", stub_urls: stub_urls)
  end

  def new(conn, _params) do
    changeset = StubUrl.changeset(%StubUrl{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"stub_url" => stub_url_params}) do
    changeset = StubUrl.changeset(%StubUrl{}, stub_url_params)

    case Repo.insert(changeset) do
      {:ok, _stub_url} ->
        conn
        |> put_flash(:info, "Stub url created successfully.")
        |> redirect(to: stub_url_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    stub_url = Repo.get!(StubUrl, id)
    send_resp(conn, stub_url.response_status, stub_url.response_body)
  end

  def edit(conn, %{"id" => id}) do
    stub_url = Repo.get!(StubUrl, id)
    changeset = StubUrl.changeset(stub_url)
    render(conn, "edit.html", stub_url: stub_url, changeset: changeset)
  end

  def update(conn, %{"id" => id, "stub_url" => stub_url_params}) do
    stub_url = Repo.get!(StubUrl, id)
    changeset = StubUrl.changeset(stub_url, stub_url_params)

    case Repo.update(changeset) do
      {:ok, stub_url} ->
        conn
        |> put_flash(:info, "Stub url updated successfully.")
        |> redirect(to: stub_url_path(conn, :show, stub_url))
      {:error, changeset} ->
        render(conn, "edit.html", stub_url: stub_url, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    stub_url = Repo.get!(StubUrl, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(stub_url)

    conn
    |> put_flash(:info, "Stub url deleted successfully.")
    |> redirect(to: stub_url_path(conn, :index))
  end
end

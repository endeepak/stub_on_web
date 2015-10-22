defmodule StubOnWeb.StubUrlControllerTest do
  use StubOnWeb.ConnCase

  alias StubOnWeb.StubUrl
  @valid_attrs %{path: "some content", response_status: 42, response_body: "some content"}
  @invalid_attrs %{}

  setup do
    conn = conn()
    {:ok, conn: conn}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, stub_url_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing stub urls"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, stub_url_path(conn, :new)
    assert html_response(conn, 200) =~ "New stub url"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, stub_url_path(conn, :create), stub_url: @valid_attrs
    assert redirected_to(conn) == stub_url_path(conn, :index)
    assert Repo.get_by(StubUrl, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, stub_url_path(conn, :create), stub_url: @invalid_attrs
    assert html_response(conn, 200) =~ "New stub url"
  end

  test "returns stub URL response status and body", %{conn: conn} do
    attrs = %{path: "hello_world", response_status: 201, response_body: "Hello world!"}
    stub_url = Repo.insert!(StubUrl.changeset(%StubUrl{}, attrs))
    
    conn = get conn, stub_url_path(conn, :show, stub_url)
    
    assert response(conn, 201) == "Hello world!"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_raise Ecto.NoResultsError, fn ->
      get conn, stub_url_path(conn, :show, "1dba9d8767ad901b6c4ff059")
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    stub_url = Repo.insert! %StubUrl{}
    conn = get conn, stub_url_path(conn, :edit, stub_url)
    assert html_response(conn, 200) =~ "Edit stub url"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    stub_url = Repo.insert! %StubUrl{}
    conn = put conn, stub_url_path(conn, :update, stub_url), stub_url: @valid_attrs
    assert redirected_to(conn) == stub_url_path(conn, :show, stub_url)
    assert Repo.get_by(StubUrl, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    stub_url = Repo.insert! %StubUrl{}
    conn = put conn, stub_url_path(conn, :update, stub_url), stub_url: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit stub url"
  end

  test "deletes chosen resource", %{conn: conn} do
    stub_url = Repo.insert! %StubUrl{}
    conn = delete conn, stub_url_path(conn, :delete, stub_url)
    assert redirected_to(conn) == stub_url_path(conn, :index)
    refute Repo.get(StubUrl, stub_url.id)
  end
end

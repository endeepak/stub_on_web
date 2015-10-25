defmodule StubOnWeb.StubUrlControllerTest do
  use StubOnWeb.ConnCase

  alias StubOnWeb.StubUrl
  @valid_attrs %{path: "hello_world", response_status: 200, response_body: "Hello world!"}
  @invalid_attrs %{}

  setup do
    conn = conn()
    {:ok, conn: conn}
  end


  test "GET /" do
    conn = get conn(), "/"

    assert html_response(conn, 200) =~ "Add"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, stub_url_path(conn, :create), stub_url: @valid_attrs

    assert redirected_to(conn) == stub_url_path(conn, :new)
    assert Repo.get_by(StubUrl, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, stub_url_path(conn, :create), stub_url: @invalid_attrs

    assert html_response(conn, 422) =~ "Add"
  end

  test "GET stub_url_path returns stub response status and body", %{conn: conn} do
    attrs = %{path: "hello_world", response_status: 201, response_body: "Hello world!"}
    stub_url = Repo.insert!(StubUrl.changeset(%StubUrl{}, attrs))
    
    conn = get conn, stub_url_path(conn, :show, "hello_world")
    
    assert response(conn, 201) == "Hello world!"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_raise Ecto.NoResultsError, fn ->
      get conn, stub_url_path(conn, :show, "nonexistent_path")
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    attrs = %{path: "hello_world", response_status: 201, response_body: "Hello world!"}
    stub_url = Repo.insert!(StubUrl.changeset(%StubUrl{}, attrs))

    conn = get conn, stub_url_path(conn, :edit, "hello_world")

    assert html_response(conn, 200) =~ "Hello world!"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    stub_url = Repo.insert! %StubUrl{}

    conn = put conn, stub_url_path(conn, :update, stub_url), stub_url: @valid_attrs

    assert redirected_to(conn) == stub_url_path(conn, :new)
    assert Repo.get_by(StubUrl, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    stub_url = Repo.insert! %StubUrl{}

    conn = put conn, stub_url_path(conn, :update, stub_url), stub_url: @invalid_attrs

    assert html_response(conn, 422) =~ "Edit"
  end
end

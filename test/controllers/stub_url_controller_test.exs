defmodule StubOnWeb.StubUrlControllerTest do
  use StubOnWeb.ConnCase

  alias StubOnWeb.StubUrl
  alias StubOnWeb.HttpHeader

  @valid_attrs %{path: "hello_world", response_status: 200, response_body: "Hello world!"}
  @invalid_attrs %{}

  setup do
    conn = conn()
    {:ok, conn: conn}
  end


  test "GET / takes to add new url page" do
    conn = get conn(), "/"

    assert html_response(conn, 200) =~ "Add"
  end

  test "GET / with previous_path shows access info" do
    conn = get conn, stub_url_path(conn, :new, previous_path: "a/b/c")

    assert html_response(conn, 200) =~ stub_url_path(conn, :show, ["a", "b", "c"])
    assert html_response(conn, 200) =~ stub_url_path(conn, :edit, ["a", "b", "c"])
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, stub_url_path(conn, :create), stub_url: @valid_attrs

    assert redirected_to(conn) == stub_url_path(conn, :new, previous_path: @valid_attrs[:path])
    assert Repo.get_by(StubUrl, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, stub_url_path(conn, :create), stub_url: @invalid_attrs

    assert html_response(conn, 422) =~ "Add"
  end

  test "GET stub_url_path returns stub response status and body", %{conn: conn} do
    attrs = %{path: "hello_world", response_status: 201, response_body: "Hello world!"}
    stub_url = Repo.insert!(StubUrl.changeset(%StubUrl{}, attrs))
    
    conn = get conn, stub_url_path(conn, :show, ["hello_world"])
    
    assert response(conn, 201) == "Hello world!"
  end

  test "GET stub_url_path works for nested routes", %{conn: conn} do
    attrs = %{path: "a/b/", response_status: 201, response_body: "Hello world!"}
    stub_url = Repo.insert!(StubUrl.changeset(%StubUrl{}, attrs))
    
    conn = get conn, stub_url_path(conn, :show, ["a", "b"])
    
    assert response(conn, 201) == "Hello world!"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_raise Ecto.NoResultsError, fn ->
      get conn, stub_url_path(conn, :show, ["nonexistent_path"])
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    attrs = %{path: "hello_world", response_status: 201, response_body: "Hello world!"}
    stub_url = Repo.insert!(StubUrl.changeset(%StubUrl{}, attrs))

    conn = get conn, stub_url_path(conn, :edit, ["hello_world"])

    assert html_response(conn, 200) =~ "Edit"
  end

  test "renders form for editing url with nested route", %{conn: conn} do
    attrs = %{path: "a/b", response_status: 201, response_body: "Hello world!"}
    stub_url = Repo.insert!(StubUrl.changeset(%StubUrl{}, attrs))

    conn = get conn, stub_url_path(conn, :edit, ["a", "b"])

    assert html_response(conn, 200) =~ "Edit"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    stub_url = Repo.insert! %StubUrl{}

    conn = put conn, stub_url_path(conn, :update, stub_url), stub_url: @valid_attrs

    assert redirected_to(conn) == stub_url_path(conn, :new, previous_path: @valid_attrs[:path])
    assert Repo.get_by(StubUrl, @valid_attrs)
  end

  test "update removes response headers from stub url when response headers are not passed in params", %{conn: conn} do
    attrs = @valid_attrs |> Map.put(:response_headers, [ %{name: "x-h1", value: "v1"}])
    stub_url = StubOnWeb.Repo.insert!(StubUrl.changeset(%StubUrl{}, attrs))
    assert length(stub_url.response_headers) == 1
    attrs_without_response_headers = @valid_attrs |> Map.delete(:response_headers)

    conn = put conn, stub_url_path(conn, :update, stub_url), stub_url: attrs_without_response_headers 

    assert length(Repo.get(StubUrl, stub_url.id).response_headers) == 0
  end

  test "update retains response headers in stub url when response headers are passed in params", %{conn: conn} do
    attrs = @valid_attrs |> Map.put(:response_headers, [ %{name: "x-h1", value: "v1"}])
    stub_url = StubOnWeb.Repo.insert!(StubUrl.changeset(%StubUrl{}, attrs))
    assert length(stub_url.response_headers) == 1

    conn = put conn, stub_url_path(conn, :update, stub_url), stub_url: attrs 

    assert length(Repo.get(StubUrl, stub_url.id).response_headers) == 1
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    stub_url = Repo.insert! %StubUrl{}

    conn = put conn, stub_url_path(conn, :update, stub_url), stub_url: @invalid_attrs

    assert html_response(conn, 422) =~ "Edit"
  end
end

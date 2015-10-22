defmodule StubOnWeb.StubUrlTest do
  use StubOnWeb.ModelCase

  alias StubOnWeb.StubUrl

  @valid_attrs %{path: "some content", response_status: 42, response_body: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = StubUrl.changeset(%StubUrl{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = StubUrl.changeset(%StubUrl{}, @invalid_attrs)
    refute changeset.valid?
  end
end

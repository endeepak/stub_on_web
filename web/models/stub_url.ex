defmodule StubOnWeb.StubUrl do
  use StubOnWeb.Web, :model

  @primary_key {:id, :binary_id, autogenerate: true}
  
  schema "stub_urls" do
    field :path, :string
    field :response_status, :integer
    field :response_body, :string
    timestamps
  end

  @required_fields ~w(path response_status)
  @optional_fields ~w(response_body)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> unique_constraint(:path)
  end
end

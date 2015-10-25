defmodule StubOnWeb.HttpHeader do
  use StubOnWeb.Web, :model

  embedded_schema do
    field :name, :string
    field :value, :string
  end

  @required_fields ~w(name value)
  @optional_fields ~w()

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end

defmodule StubOnWeb.StubUrl do
  use StubOnWeb.Web, :model

  @primary_key {:id, :binary_id, autogenerate: true}
  
  schema "stub_urls" do
    field :path, :string
    field :response_status, :integer
    field :response_body, :string
    embeds_many :response_headers, StubOnWeb.HttpHeader, on_replace: :delete
    timestamps
  end

  @required_fields ~w(path response_status response_headers)
  @optional_fields ~w(response_body)

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> unique_constraint(:path)
  end

  def path_fragments(model) do
    model.path 
    |> String.split("/")
  end
end

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

defmodule StubOnWeb.HttpRequest do
  use StubOnWeb.Web, :model

  embedded_schema do
    field :method, :string
    field :url, :string
    field :body, :string
    embeds_many :headers, StubOnWeb.HttpHeader, on_replace: :delete
  end

  @required_fields ~w(method url)
  @optional_fields ~w(headers body)

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end

defmodule StubOnWeb.HttpResponse do
  use StubOnWeb.Web, :model

  embedded_schema do
    field :status, :integer
    field :body, :string
    embeds_many :headers, StubOnWeb.HttpHeader, on_replace: :delete
  end

  @required_fields ~w(status)
  @optional_fields ~w(headers body)

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end

defmodule StubOnWeb.StubUrlCall do
  use StubOnWeb.Web, :model

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id  

  schema "stub_url_calls" do
    embeds_one :request, StubOnWeb.HttpRequest, on_replace: :delete
    embeds_one :response, StubOnWeb.HttpResponse, on_replace: :delete
    belongs_to :stub_url, StubOnWeb.StubUrl
    timestamps
  end

  @required_fields ~w(request response stub_url_id)
  @optional_fields ~w()

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end

defmodule StubOnWeb.StubUrl do
  use StubOnWeb.Web, :model

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  
  schema "stub_urls" do
    field :path, :string
    field :response_status, :integer
    field :response_body, :string
    embeds_many :response_headers, StubOnWeb.HttpHeader, on_replace: :delete
    has_many :calls, StubOnWeb.StubUrlCall, on_delete: :delete_all, on_replace: :delete
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
    path = model.path || ""
    String.split(path, "/")
  end
end

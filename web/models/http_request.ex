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

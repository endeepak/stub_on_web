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
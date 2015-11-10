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
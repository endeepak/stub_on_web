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
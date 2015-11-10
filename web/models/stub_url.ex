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

  alias StubOnWeb.HttpHeader
  alias StubOnWeb.StubUrlCall
  alias StubOnWeb.Repo

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  
  schema "stub_urls" do
    field :path, :string
    field :response_status, :integer
    field :response_body, :string
    field :min_delay, :integer, default: 0
    embeds_many :response_headers, HttpHeader, on_replace: :delete
    has_many :calls, StubUrlCall, on_delete: :delete_all, on_replace: :delete
    timestamps
  end

  @required_fields ~w(path response_status response_headers)
  @optional_fields ~w(response_body min_delay)
  @number_milliseconds_in_a_second 1_000

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> unique_constraint(:path)
  end

  def path_fragments(model) do
    path = model.path || ""
    String.split(path, "/")
  end

  def notify_call(stub_url, conn) do
    _capture_call(stub_url, conn)
    min_delay = stub_url.min_delay || 0
    :timer.sleep(min_delay * @number_milliseconds_in_a_second)
  end

  def _capture_call(stub_url, conn) do
    request_headers = _get_request_headers(conn)
    request_body = conn.private[:raw_request_body]
    request_data = %{url: _get_url_from_conn(conn), body: request_body, method: conn.method, headers: request_headers}
    response_headers = Enum.map(stub_url.response_headers, fn header -> %{name: header.name, value: header.value} end)
    response_data = %{status: stub_url.response_status, headers: response_headers, body: stub_url.response_body}
    call_data = %{request: request_data, response: response_data, stub_url_id: stub_url.id}
    changeset = StubUrlCall.changeset(%StubUrlCall{}, call_data)
    Repo.insert!(changeset)

    max_stub_url_calls = Application.get_env(:stub_on_web, :max_stub_url_calls)
    #TODO: Optimize by getting nth recent and single delete for all calls older than that
    older_calls = Repo.all from c in StubUrlCall,
                         where: c.stub_url_id == ^stub_url.id,
                         order_by: [desc: c.inserted_at],
                         offset: ^max_stub_url_calls
    Enum.each older_calls, &Repo.delete!(&1)
  end

  def _get_url_from_conn(conn) do
    if(conn.query_string != nil and conn.query_string != "") do conn.request_path <> "?" <> conn.query_string else conn.request_path end
  end

  def _get_request_headers(conn) do
    ignore_request_headers = Application.get_env(:stub_on_web, :ignore_request_headers)
    normarlized_ignore_request_headers = ignore_request_headers |> Enum.map(&String.downcase(&1))
    Enum.into(conn.req_headers, %{})
    |> Map.drop(normarlized_ignore_request_headers)
    |> Enum.map(fn {name, value} -> %{name: name, value: value} end)
  end
end

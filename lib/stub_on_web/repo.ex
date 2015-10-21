defmodule StubOnWeb.Repo do
  use Ecto.Repo,
    otp_app: :stub_on_web,
    adapter: Mongo.Ecto
end

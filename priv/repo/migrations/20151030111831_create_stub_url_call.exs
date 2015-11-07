defmodule StubOnWeb.Repo.Migrations.CreateStubUrlCall do
  use Ecto.Migration

  def change do
    create table(:stub_url_calls)
    create index(:stub_url_calls, [:stub_url_id])
  end
end

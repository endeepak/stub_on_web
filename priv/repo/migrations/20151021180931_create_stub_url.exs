defmodule StubOnWeb.Repo.Migrations.CreateStubUrl do
  use Ecto.Migration

  def change do
    create table(:stub_urls)
    create unique_index(:stub_urls, [:path])
  end
end

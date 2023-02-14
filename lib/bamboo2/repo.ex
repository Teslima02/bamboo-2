defmodule Bamboo2.Repo do
  use Ecto.Repo,
    otp_app: :bamboo2,
    adapter: Ecto.Adapters.Postgres
end

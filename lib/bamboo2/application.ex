defmodule Bamboo2.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      Bamboo2Web.Telemetry,
      # Start the Ecto repository
      Bamboo2.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Bamboo2.PubSub},
      # Start Finch
      {Finch, name: Bamboo2.Finch},
      # Start the Endpoint (http/https)
      Bamboo2Web.Endpoint
      # Start a worker by calling: Bamboo2.Worker.start_link(arg)
      # {Bamboo2.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Bamboo2.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    Bamboo2Web.Endpoint.config_change(changed, removed)
    :ok
  end
end

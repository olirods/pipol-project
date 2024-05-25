defmodule Pipol.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PipolWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:pipol, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Pipol.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Pipol.Finch},
      # Start a worker by calling: Pipol.Worker.start_link(arg)
      # {Pipol.Worker, arg},
      # Start to serve requests, typically the last entry
      PipolWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Pipol.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PipolWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

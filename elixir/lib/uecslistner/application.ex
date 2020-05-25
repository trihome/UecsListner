defmodule Uecslistner.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  import Supervisor.Spec

  def start(_type, _args) do
    children = [
      # Starts a worker by calling: Uecslistner.Worker.start_link(arg)
      # {Uecslistner.Worker, arg}
      worker(Uecslistner.Udp, [16520, [name: :udpserver]]),
      {Uecslistner.Dbuecs, 0},
      worker(Uecslistner.DbUniqQueue, [Map.new(), [name: :dbuniqqueue]]),
      worker(Uecslistner.Auto, [nil, [name: :auto]])
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Uecslistner.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

defmodule ElixirChatbotInterface.Supervisor do
  use Supervisor
  require Logger

  alias ElixirChatbotInterface.DialogflowWebhookService, as: DialogflowWebhookService
  alias ElixirChatbotInterface.Registry, as: Registry
  def start_link(state) do
    Supervisor.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(_state) do
    children = [
      {Registry, name: Registry}
    ]

    Logger.info("#{inspect(children)}")

    Supervisor.init(children, strategy: :one_for_one)
  end
end

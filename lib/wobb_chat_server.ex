defmodule ElixirChatbotInterface do
  @moduledoc """
  ElixirChatbotInterface keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  use Application

  def start(_type, _args) do
    ElixirChatbotInterface.Supervisor.start_link(name: ElixirChatbotInterface.Supervisor)
  end
end

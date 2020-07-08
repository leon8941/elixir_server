defmodule ElixirChatbotInterface.Repo do
  use Ecto.Repo,
    otp_app: :elixir_chatbot_interface,
    adapter: Ecto.Adapters.Postgres
end

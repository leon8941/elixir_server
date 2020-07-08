# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :elixir_chatbot_interface,
  ecto_repos: [ElixirChatbotInterface.Repo],
  sendbird_token: System.get_env("SENDBIRD_TOKEN"),
  sendbird_app_id: System.get_env("SENDBIRD_APP_ID"),
  dialogflow_project_id: System.get_env("DIALOGFLOW_PROJECT_ID")

# Configures the endpoint
config :elixir_chatbot_interface, ElixirChatbotInterfaceWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: System.get_env("SECRET_KEY_BASE"),
  render_errors: [view: ElixirChatbotInterfaceWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: ElixirChatbotInterface.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :elixir_chatbot_interface, ElixirChatbotInterfaceWeb.Auth.Guardian,
  issuer: "elixir_chatbot_interface",
  secret_key: System.get_env("GUARDIAN_SECRET_KEY")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"


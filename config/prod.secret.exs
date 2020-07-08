# In this file, we load production configuration and
# secrets from environment variables. You can also
# hardcode secrets, although such is generally not
# recommended and you have to remember to add this
# file to your .gitignore.
use Mix.Config

database_url =
  System.get_env("DATABASE_URL") ||
    raise """
    environment variable DATABASE_URL is missing.
    For example: ecto://USER:PASS@HOST/DATABASE
    """

config :elixir_chatbot_interface, ElixirChatbotInterface.Repo,
  ssl: true,
  url: database_url,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

secret_key_base =
  System.get_env("SECRET_KEY_BASE") ||
    raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

config :goth,
  type: System.get_env("type"),
  project_id: System.get_env("project_id"),
  private_key_id: System.get_env("private_key_id"),
  private_key: System.get_env("private_key"),
  client_email: System.get_env("client_email"),
  client_id: System.get_env("client_id"),
  auth_uri: System.get_env("auth_uri"),
  token_uri: System.get_env("token_uri"),
  auth_provider_x509_cert_url: System.get_env("auth_provider_x509_cert_url"),
  client_x509_cert_url: System.get_env("client_x509_cert_url")

config :elixir_chatbot_interface, ElixirChatbotInterfaceWeb.Endpoint,
  http: [:inet6, port: String.to_integer(System.get_env("PORT") || "4000")],
  secret_key_base: secret_key_base

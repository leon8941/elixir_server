defmodule ElixirChatbotInterfaceWeb.Router do
  use ElixirChatbotInterfaceWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", ElixirChatbotInterfaceWeb do
    pipe_through :api

    # Sendbird's chatbot callback URL
    get "/dialogflow_webhook", DialogflowWebhookController, :index
    post "/dialogflow_webhook", DialogflowWebhookController, :create

    get "/job_application/:id", JobApplicationController, :show
  end

  scope "/api", ElixirChatbotInterfaceWeb do
    pipe_through [:api, :auth]
  end

  pipeline :browser do
    plug(:accepts, ["html"])
  end

  scope "/", ElixirChatbotInterfaceWeb do
    pipe_through :browser
    get "/", DefaultController, :index
    get "/loaderio-0b69a29f9a87b40321e4d76f77c445a2", LoaderIOController, :index
  end
end

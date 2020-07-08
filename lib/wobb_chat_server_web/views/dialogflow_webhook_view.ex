defmodule ElixirChatbotInterfaceWeb.DialogflowWebhookView do
  use ElixirChatbotInterfaceWeb, :view
  alias ElixirChatbotInterfaceWeb.DialogflowWebhookView

  def render("index.json", %{params: _params}) do
    %{
      params: "INDEX"
    }
  end

  def render("show.json", %{}) do
    %{
      status: 200
    }
  end
end

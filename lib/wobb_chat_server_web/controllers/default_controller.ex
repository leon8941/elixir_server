defmodule ElixirChatbotInterfaceWeb.DefaultController do
  use ElixirChatbotInterfaceWeb, :controller

  def index(conn, _params) do
    text(conn, "ElixirChatbotInterfaceWeb!")
  end
end

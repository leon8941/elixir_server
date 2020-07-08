defmodule ElixirChatbotInterfaceWeb.LoaderIOController do
  use ElixirChatbotInterfaceWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
    # text(conn, "LoaderIOController!")
  end
end

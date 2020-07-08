require Logger

defmodule ElixirChatbotInterfaceWeb.DialogflowWebhookController do
  import Ecto.Query, warn: false
  use ElixirChatbotInterfaceWeb, :controller

  alias ElixirChatbotInterface.SystemSetting
  alias ElixirChatbotInterface.Repo

  alias ElixirChatbotInterface.DialogflowWebhookService, as: DialogflowWebhookService

  action_fallback ElixirChatbotInterfaceWeb.FallbackController

  def index(conn, params) do
    render(conn, "index.json", params: params)
  end

  def create(conn, params) do
    check_system_setting = Repo.one(from obj in SystemSetting, where: obj.name == "use_aivi_controller" )

    if !(check_system_setting |> Map.from_struct).boolean_val do
      channel_url = params["channel"]["channel_url"]
      bot_id = params["bot"]["bot_userid"]
      message = params["message"]["text"]
      created_at = DateTime.from_unix(params["message"]["created_at"], :millisecond)

      children = [ElixirChatbotInterface.DialogflowWebhookService.child_spec([])]

      {:ok, pid} = Supervisor.start_link(children, strategy: :one_for_one)

      DialogflowWebhookService.process_dialogflow_query(DialogflowWebhookService, %{
        channel_url: channel_url,
        bot_id: bot_id,
        message: message,
        created_at: created_at,
        pid: pid
      })

      Logger.info("SENDBIRD CALLBACK END FOR #{channel_url} for proccesses : #{inspect(pid)}")
    else
      Logger.info("SENDBIRD CALLBACK NOT EXECUTING SINCE 'use_aivi_controller' IN SYSTEM SETTING IS TRUE")
    end
    render(conn, "show.json")
  end
end

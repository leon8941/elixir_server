require Logger

defmodule ElixirChatbotInterface.DialogflowWebhookService do
  # Dialogflow's algorithm are returned here, process by GenServer.

  use GenServer

  alias Client

  alias ElixirChatbotInterface.Company.Job, as: Job

  @sendbird_token Application.get_env(:elixir_chatbot_interface, :sendbird_token)
  @sendbird_app_id Application.get_env(:elixir_chatbot_interface, :sendbird_app_id)
  @dialogflow_project_id Application.get_env(:elixir_chatbot_interface, :dialogflow_project_id)

  #######
  # API #
  #######
  def start_link(state) do
    GenServer.start_link(__MODULE__, [state], name: __MODULE__)
  end

  def start_child(supervisor, child_spec) do
    GenServer.call(supervisor, {:start_child, child_spec})
  end

  def terminate_child(supervisor, pid) when is_pid(pid) do
    GenServer.call(supervisor, {:terminate_child, pid})
  end

  def restart_child(supervisor, pid, child_spec) when is_pid(pid) do
    GenServer.call(supervisor, {:restart_child, pid, child_spec})
  end

  def count_children(supervisor) do
    GenServer.call(supervisor, :count_children)
  end

  def which_children(supervisor) do
    GenServer.call(supervisor, :which_children)
  end

  def process_dialogflow_query(server, obj) do
    GenServer.cast(server, {:process_dialogflow_query, obj})
  end

  ######################
  # Callback Functions #
  ######################
  @impl true
  def init([child_spec_list]) do
    Process.flag(:trap_exit, true)

    state =
      child_spec_list
      |> start_children
      |> Enum.into(Map.new())

    {:ok, state}
    {:ok, state}
  end

  @impl true
  def handle_call({:read}, from, list) do
    {:reply, list, list}
  end

  @impl true
  def handle_call({:start_child, child_spec}, _from, state) do
    case start_child(child_spec) do
      {:ok, pid} ->
        new_state = state |> Map.put(pid, child_spec)
        {:reply, {:ok, pid}, new_state}

      :error ->
        {:reply, {:error, "error starting child"}, state}
    end
  end

  @impl true
  def handle_call({:terminate_child, pid}, _from, state) do
    case terminate_child(pid) do
      :ok ->
        new_state = state |> Map.delete(pid)
        {:reply, :ok, new_state}

      :error ->
        {:reply, {:error, "error terminating child"}, state}
    end
  end

  def handle_call({:restart_child, old_pid}, _from, state) do
    case Map.fetch(state, old_pid) do
      {:ok, child_spec} ->
        case restart_child(old_pid, child_spec) do
          {:ok, {pid, child_spec}} ->
            new_state =
              state
              |> Map.delete(old_pid)
              |> Map.put(pid, child_spec)

            {:reply, {:ok, pid}, new_state}

          :error ->
            {:reply, {:error, "error restarting child"}, state}
        end

      _ ->
        {:reply, :ok, state}
    end
  end

  def handle_call(:count_children, _from, state) do
    {:reply, Map.size(state), state}
  end

  def handle_call(:which_children, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_info({:EXIT, from, :killed}, state) do
    new_state = state |> Map.delete(from)
    {:noreply, new_state}
  end

  def handle_info({:EXIT, from, :normal}, state) do
    new_state = state |> Map.delete(from)
    {:noreply, new_state}
  end

  def handle_info({:EXIT, old_pid, _reason}, state) do
    case Map.fetch(state, old_pid) do
      {:ok, child_spec} ->
        case restart_child(old_pid, child_spec) do
          {:ok, {pid, child_spec}} ->
            new_state =
              state
              |> Map.delete(old_pid)
              |> Map.put(pid, child_spec)

            {:noreply, new_state}

          :error ->
            {:noreply, state}
        end

      _ ->
        {:noreply, state}
    end
  end

  @impl true
  def handle_cast({:process_dialogflow_query, obj}, list) do
    project_id = @dialogflow_project_id
    channel_url = obj[:channel_url]
    bot_id = obj[:bot_id]
    message = obj[:message]
    created_at = obj[:created_at]
    channel_metadata = sendbird_get_channel_metadata(channel_url)

    session_id = channel_metadata[:cb_session]
    last_context = channel_metadata[:cb_last_context] |> String.downcase()
    cb_status = channel_metadata[:cb_status]

    if is_nil(session_id) do
      Logger.info("session id is NIL.")
    else
      if Integer.parse(cb_status) == {12, ""} do
        sendbird_remove_aivi_from_channel(channel_url)
      else
        channel_info = sendbird_view_channel(channel_url)

        if channel_info[:error] === nil do
          Logger.info("DialogflowWebhook channel url #{channel_url} start send_query_to_dialogflow")

          send_query_to_dialogflow(
            session_id,
            message,
            bot_id,
            channel_url,
            last_context,
            project_id
          )
        else
          Logger.info("aiviError: Channel doesn't exist, channelUrl: #{channel_url}")
        end
      end
    end

    {:noreply, list}
  end

  @impl true
  def terminate(_reason, state) do
    terminate_children(state)
    :ok
  end

  #####################
  # Private Functions #
  #####################
  defp start_child({mod, fun, args}) do
    case apply(mod, fun, args) do
      pid when is_pid(pid) ->
        {:ok, pid}

      _ ->
        :error
    end
  end

  defp start_children([child_spec | rest]) do
    case start_child(child_spec) do
      {:ok, pid} ->
        [{pid, child_spec} | start_children(rest)]

      :error ->
        :error
    end
  end

  defp start_children([]), do: []

  defp terminate_child(pid) do
    Process.exit(pid, :kill)
    :ok
  end

  defp restart_child(pid, child_spec) when is_pid(pid) do
    case terminate_child(pid) do
      :ok ->
        case start_child(child_spec) do
          {:ok, new_pid} ->
            {:ok, {new_pid, child_spec}}

          :error ->
            :error
        end

      :error ->
        :error
    end
  end

  def terminate_children([]) do
    :ok
  end

  def terminate_children(child_specs) do
    child_specs |> Enum.each(fn {pid, _} -> terminate_child(pid) end)
  end

  defp send_query_to_dialogflow(
         session_id,
         message,
         bot_id,
         channel_url,
         last_context,
         project_id
       ) do
    {:ok, goth_obj} = Goth.Token.for_scope("https://www.googleapis.com/auth/dialogflow")
    token = Map.from_struct(goth_obj)

    conn = GoogleApi.Dialogflow.V2.Connection.new(token[:token])

    if message === "hi" || message === "i need a job" do
      dialogflow_delete_all_context_rest(conn, project_id, session_id)

      dialogflow_create_specific_context_rest(
        conn,
        project_id,
        session_id,
        "DefaultWelcomeIntent-followup",
        2
      )

      sessions_contexts_list = dialogflow_get_all_context_rest(conn, project_id, session_id)
    else
      sessions_contexts_list = dialogflow_get_all_context_rest(conn, project_id, session_id)
      current_contexts_map_list = sessions_contexts_list |> elem(1) |> Map.from_struct()

      # Contexts is present in dialogflow
      if current_contexts_map_list.contexts != nil do
        current_contexts_map_enum = current_contexts_map_list.contexts |> Enum.at(0)
        current_contexts_url = current_contexts_map_enum.name

        current_contexts_name =
          current_contexts_url |> String.split("/") |> List.last() |> String.downcase()

        match = intents_checking(conn, project_id, last_context)

        # If sendbird's context matches with the intents name from dialogflow
        if match === true do
          Logger.info(
            "match true current_contexts_name: #{current_contexts_name}  last_context: #{
              last_context
            }"
          )

          # if current context from dialogflow doesn't match with sendbird's last context, deletes all contexts in dialogflow and creates a new one with the context provided from sendbird
          if current_contexts_name != last_context do
            lifespan = 1

            Logger.info("current_contexts_name != last_context")
            dialogflow_delete_all_context_rest(conn, project_id, session_id)

            dialogflow_create_specific_context_rest(
              conn,
              project_id,
              session_id,
              last_context,
              lifespan
            )
          else
            lifespan = 1

            dialogflow_delete_all_context_rest(conn, project_id, session_id)
            # Use dialogflow's current contexts name instead since sendbird's one is wrong
            dialogflow_create_specific_context_rest(
              conn,
              project_id,
              session_id,
              current_contexts_name,
              lifespan
            )
          end
        else
          Logger.info("match false")
        end

        # Contexts is not present in dialogflow
      else
        fn_last_context = fn ->
          # if sendbird's last context is empty
          if String.trim(last_context) == "" do
            %{lifespan: 2, last_context: "DefaultWelcomeIntent-followup"}
            # Use context from sendbird if its present
          else
            match = intents_checking(conn, project_id, last_context)

            if match == true do
              %{lifespan: 2, last_context: last_context}
            else
              %{lifespan: 2, last_context: "DefaultWelcomeIntent-followup"}
            end
          end
        end

        context_map = fn_last_context.()

        dialogflow_delete_all_context_rest(conn, project_id, session_id)

        dialogflow_create_specific_context_rest(
          conn,
          project_id,
          session_id,
          context_map[:last_context],
          context_map[:lifespan]
        )
      end
    end

    # Send messages
    query_input = %GoogleApi.Dialogflow.V2.Model.GoogleCloudDialogflowV2QueryInput{
      text: %GoogleApi.Dialogflow.V2.Model.GoogleCloudDialogflowV2TextInput{
        text: message,
        languageCode: "en-US"
      }
    }

    detect_intent_response =
      dialogflow_detect_intent_rest(conn, project_id, session_id, query_input)

    Logger.info("detect_intent_response")

    detect_intent = detect_intent_response |> elem(1) |> Map.from_struct()
    queryResult = detect_intent[:queryResult]

    queryResultTuple = queryResult |> Map.from_struct()
    fulfillmentText = queryResultTuple[:fulfillmentText]
    outputContextsMap = queryResultTuple[:outputContexts]
    outputContextsTuple = outputContextsMap |> List.first() |> Map.from_struct()

    outputContextsName =
      outputContextsTuple[:name] |> String.split("/") |> List.last() |> String.downcase()

    bot_message_body = %{
      message: fulfillmentText,
      channel_url: channel_url,
      mark_as_read: true
    }

    Logger.info("bot_message_response")
    send_bot_message_to_sendbird(bot_message_body, bot_id)

    fn_sendbird_body = fn ->
      if outputContextsName == "end-interview" do
        sendbird_remove_aivi_from_channel(channel_url)
        %{
          metadata: %{
            cb_last_context: outputContextsName,
            cb_status: 12
          },
          upsert: true
        }
      else
        %{
          metadata: %{
            cb_last_context: outputContextsName,
            cb_status: 11
          },
          upsert: true
        }
      end
    end

    sendbird_body = fn_sendbird_body.()

    sendbird_update_channel_metadata(channel_url, sendbird_body)

    cb_status_ = sendbird_body[:metadata][:cb_status]
    job_application_ = Job.get_job_application(String.to_integer(session_id))

    if job_application_ do
      IO.puts "job_application_ true"
      Job.update_job_application(
        job_application_,
        %{
          bot_context: String.downcase(outputContextsName),
          chat_status: 2,
          chatbot_status: cb_status_,
          updated_at: NaiveDateTime.utc_now()
        }
      )
    end
  end

  defp intents_checking(conn, project_id, last_context) do
    intents_list_tuple = dialogflow_list_all_intent_rest(conn, project_id)
    intents_list_map = intents_list_tuple |> elem(1) |> Map.from_struct()
    intents_list = intents_list_map.intents

    Enum.any?(intents_list, fn intent ->
      if intent.inputContextNames != nil do
        inputContextNames = List.first(intent.inputContextNames)
        inputContextName = inputContextNames |> String.split("/") |> List.last()
        last_context == inputContextName
      end
    end)
  end

  ######### DIALOGFLOW API CALL #########
  defp dialogflow_get_all_context_rest(conn, project_id, session_id) do
    GoogleApi.Dialogflow.V2.Api.Projects.dialogflow_projects_agent_sessions_contexts_list(
      conn,
      "projects/#{project_id}/agent/sessions/#{session_id}"
    )
  end

  defp dialogflow_detect_intent_rest(conn, project_id, session_id, query_input) do
    df_params = [
      {:body,
       %GoogleApi.Dialogflow.V2.Model.GoogleCloudDialogflowV2DetectIntentRequest{
         queryInput: query_input
       }}
    ]

    GoogleApi.Dialogflow.V2.Api.Projects.dialogflow_projects_agent_sessions_detect_intent(
      conn,
      "projects/#{project_id}/agent/sessions/#{session_id}",
      df_params
    )
  end

  defp dialogflow_create_specific_context_rest(
         conn,
         project_id,
         session_id,
         last_context,
         lifespan
       ) do
    df_params = [
      {:body,
       %GoogleApi.Dialogflow.V2.Model.GoogleCloudDialogflowV2Context{
         lifespanCount: lifespan,
         name: "projects/#{project_id}/agent/sessions/#{session_id}/contexts/#{last_context}"
       }}
    ]

    GoogleApi.Dialogflow.V2.Api.Projects.dialogflow_projects_agent_sessions_contexts_create(
      conn,
      "projects/#{project_id}/agent/sessions/#{session_id}",
      df_params
    )
  end

  defp dialogflow_delete_all_context_rest(conn, project_id, session_id) do
    GoogleApi.Dialogflow.V2.Api.Projects.dialogflow_projects_agent_sessions_delete_contexts(
      conn,
      "projects/#{project_id}/agent/sessions/#{session_id}"
    )
  end

  defp dialogflow_list_all_intent_rest(conn, project_id) do
    GoogleApi.Dialogflow.V2.Api.Projects.dialogflow_projects_agent_intents_list(
      conn,
      "projects/#{project_id}/agent"
    )
  end

  ######### SENDBIRD API CALL ###########
  defp sendbird_view_channel(channel_url) do
    channel_type = "group_channels"
    baselink = "https://api-#{@sendbird_app_id}.sendbird.com/v3/#{channel_type}/#{channel_url}"
    headers = ["Api-Token": @sendbird_token, "Content-Type": "application/json; Charset=utf-8"]
    # A response Struct is returned
    # A function from Kernel, accessing Struct at position number 2
    baselink |> Client.get(headers) |> elem(1)
  end

  defp sendbird_get_channel_metadata(channel_url) do
    channel_type = "group_channels"

    baselink =
      "https://api-#{@sendbird_app_id}.sendbird.com/v3/#{channel_type}/#{channel_url}/metadata"

    headers = ["Api-Token": @sendbird_token, "Content-Type": "application/json; Charset=utf-8"]
    # A response Struct is returned
    # A function from Kernel, accessing Struct at position number 2
    baselink |> Client.get(headers) |> elem(1)
  end

  defp sendbird_update_channel_metadata(channel_url, body) do
    channel_type = "group_channels"

    baselink =
      "https://api-#{@sendbird_app_id}.sendbird.com/v3/#{channel_type}/#{channel_url}/metadata"

    headers = ["Api-Token": @sendbird_token, "Content-Type": "application/json; Charset=utf-8"]
    # A response Struct is returned
    # A function from Kernel, accessing Struct at position number 2
    baselink |> Client.modify(:put, headers, body) |> elem(1)
  end

  defp send_bot_message_to_sendbird(body, bot_id) do
    baselink = "https://api-#{@sendbird_app_id}.sendbird.com/v3/bots/#{bot_id}/send"
    headers = ["Api-Token": @sendbird_token, "Content-Type": "application/json; Charset=utf-8"]
    # A response Struct is returned
    # A function from Kernel, accessing Struct at position number 2
    baselink |> Client.modify(:post, headers, body) |> elem(1)
  end

  defp sendbird_remove_aivi_from_channel(channel_url) do
    baselink =
      "https://api-#{@sendbird_app_id}.sendbird.com/v3/group_channels/#{channel_url}/leave"

    headers = ["Api-Token": @sendbird_token, "Content-Type": "application/json; Charset=utf-8"]

    body = %{
      user_ids: ["123rwwer32"]
    }

    # A response Struct is returned
    # A function from Kernel, accessing Struct at position number 2
    baselink |> Client.modify(:put, headers, body) |> elem(1)
  end
end

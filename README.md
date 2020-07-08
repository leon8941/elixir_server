# Elixir Chat Interface Server
Configuring Sendbird’s bot’s callback url.

1. Get **Api-token** and **application-id** from Sendbird for make api call.
2. To view current bot’s information, use this api call - https://docs.sendbird.com/platform/bot_interface#3_view_a_bot.
3. To update Sendbird’s bot callback url, refer to this doc - https://docs.sendbird.com/platform/bot_interface#3_update_a_bot.
    1. For the request body, only need set the **bot_callback_url** as "https://{**your-callback-server-url**}/api/dialogflow_webhook".
    2. Then, any messages that sent to a group channel that has Chatbot inside that group will forward data to the server specify in **bot_callback_url**.

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server` or `source .env && mix phx.server`
  * Start Elixir console with  `iex -S mix`
  * To start Phoenix project with debugging mode, run `source .env && iex -S mix phx.server `

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix


## Sample Command Line

  * mix phx.gen.json Directory Business businesses name:string description:text tag:string
  * mix phx.gen.schema Company.Job.JobApplication job_applications id:integer updated_at:datetime ...
defmodule ElixirChatbotInterface.Company.Job.JobApplication do
  use Ecto.Schema
  import Ecto.Changeset

  schema "job_applications" do
    field :aivi_transcript_sent, :boolean, default: false
    field :background_job_last_run_at, :naive_datetime
    field :background_job_status, :boolean, default: false
    field :bot_context, :string
    field :chat_status, :integer
    field :chatbot_status, :integer
    field :created_at, :naive_datetime
    field :ever_contacted, :boolean, default: false
    field :ever_shortlisted, :boolean, default: false
    field :job_id, Ecto.UUID
    field :job_renewal_date, :naive_datetime
    field :last_message_receive_at, :naive_datetime
    field :last_message_sent_at, :naive_datetime
    field :notes, :string
    field :relevance, :integer
    field :resume_sent, :boolean, default: false
    field :sendbird_channel_url, :string
    field :sendbird_migrated, :boolean, default: false
    field :sendbird_sync_date, :naive_datetime
    field :sendbird_sync_status, :boolean, default: false
    field :spam, :boolean, default: false
    field :state, :string
    field :status, :boolean, default: false
    field :user_id, Ecto.UUID
    field :updated_at, :naive_datetime
  end

  @doc false
  def changeset(job_application, attrs) do
    job_application
    |> cast(attrs, [
      :id,
      :updated_at,
      :created_at,
      :resume_sent,
      :job_id,
      :user_id,
      :status,
      :job_renewal_date,
      :spam,
      :state,
      :ever_contacted,
      :ever_shortlisted,
      :chat_status,
      :relevance,
      :notes,
      :chatbot_status,
      :bot_context,
      :sendbird_migrated,
      :sendbird_channel_url,
      :background_job_status,
      :background_job_last_run_at,
      :last_message_sent_at,
      :last_message_receive_at,
      :sendbird_sync_status,
      :sendbird_sync_date,
      :aivi_transcript_sent
    ])
    |> validate_required([
      :id,
      :updated_at,
      :created_at
    ])
  end
end

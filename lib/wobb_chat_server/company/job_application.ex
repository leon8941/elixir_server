defmodule ElixirChatbotInterface.Company.Job do
  import Ecto.Query, warn: false

  alias ElixirChatbotInterface.Repo
  alias ElixirChatbotInterface.Company.Job.JobApplication

  def get_job_application(id) do
    Repo.get(JobApplication, id)
  end

  def update_job_application(%JobApplication{} = job_application, attrs) do
    job_application
    |> JobApplication.changeset(attrs)
    |> Repo.update()
  end
end

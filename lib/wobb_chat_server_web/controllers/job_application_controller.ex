defmodule ElixirChatbotInterfaceWeb.JobApplicationController do
  use ElixirChatbotInterfaceWeb, :controller

  alias ElixirChatbotInterface.Company.Job

  action_fallback ElixirChatbotInterfaceWeb.FallbackController

  def show(conn, %{"id" => id}) do
    job_application = Job.get_job_application(id)

    render(conn, "show.json", job_application: job_application)
  end
end

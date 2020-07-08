defmodule ElixirChatbotInterfaceWeb.JobApplicationView do
  use ElixirChatbotInterfaceWeb, :view
  alias ElixirChatbotInterfaceWeb.JobApplicationView

  def render("show.json", %{job_application: job_application}) do
    %{data: render_one(job_application, JobApplicationView, "job_application.json")}
  end

  def render("job_application.json", %{job_application: job_application}) do
    %{
      id: job_application.id,
      job_id: job_application.job_id,
      user_id: job_application.user_id
    }
  end
end

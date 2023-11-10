class AdminMailerPreview < ActionMailer::Preview
  def issues_report
    AdminMailer.with(email_address: 'test@blah.com', user: User.admin.last).issues_report
  end

  def background_job_complete
    AdminMailer.with(to: User.admin.first, title: 'Background Job', summary: 'A background job that did something useful has completed', results_url: 'https://example.org').background_job_complete
  end
end

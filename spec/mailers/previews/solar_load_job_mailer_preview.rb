class SolarLoaderJobMailer < ActionMailer::Preview
  def background_job_complete
    SolarLoaderJobMailer.with(to: User.admin.first, title: 'Background Job', summary: 'A background job that did something useful has completed', results_url: 'https://example.org').job_complete
  end
end

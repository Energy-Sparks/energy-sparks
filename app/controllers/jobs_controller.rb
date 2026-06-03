class JobsController < DownloadableController
  skip_before_action :authenticate_user!

  def index
    @jobs = Job.current_jobs.by_created_date
  end

  private

  def downloadable_model_class
    Job
  end
end

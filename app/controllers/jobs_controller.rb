class JobsController < ApplicationController
  include StorageHelper
  skip_before_action :authenticate_user!

  def index
    @jobs = Job.current_jobs.by_created_date
  end

  def download
    job = Job.find_by(id: params[:id])
    if job.present?
      serve_from_storage(job.file, params[:serve])
    else
      route_not_found
    end
  end
end

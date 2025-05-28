class JobsController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    @jobs = Job.current_jobs.by_created_date
  end

  def download
    job = Job.find_by(id: params[:id])
    if job.present?
      disposition = params[:serve] == 'download' ? 'attachment' : 'inline'
      redirect_to cdn_link_url(job.file, params: { disposition: disposition })
    else
      route_not_found
    end
  end
end

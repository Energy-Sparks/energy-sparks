class CaseStudiesController < ApplicationController
  skip_before_action :authenticate_user!
  def index
    @case_studies = CaseStudy.order(position: :asc)
  end

  def download
    resource = CaseStudy.find_by(id: params[:id])
    if resource.present?
      file = resource.t_attached(:file, params[:locale])
      disposition = params[:serve] == 'download' ? 'attachment' : 'inline'
      redirect_to cdn_link_url(file, params: { disposition: disposition })
    else
      route_not_found
    end
  end
end

class CaseStudiesController < ApplicationController
  include StorageHelper
  skip_before_action :authenticate_user!
  def index
    @case_studies = CaseStudy.order(position: :asc)
  end

  def download
    resource = CaseStudy.find_by(id: params[:id])
    if resource.present?
      file = resource.t_attached(:file, params[:locale])
      serve_from_storage(file, params[:serve])
    else
      render file: Rails.public_path.join('404.html'), status: :not_found, layout: false
    end
  end
end

class CaseStudiesController < ApplicationController
  include StorageHelper
  skip_before_action :authenticate_user!

  def index
    @case_studies = if Flipper.enabled?(:new_case_studies_page, current_user)
                      CaseStudy.published.order(:position)
                    else
                      CaseStudy.order(:position)
                    end

    if Flipper.enabled?(:new_case_studies_page, current_user)
      @show_images = @case_studies.without_images.none? || params[:show_images]

      if params[:show_images]
        @case_studies = @case_studies.to_a.sort_by do |cs|
          [(cs.image.attached? ? 0 : 1), cs.position]
        end
      end
    end

    layout = Flipper.enabled?(:new_case_studies_page, current_user) ? 'home' : 'application'
    render :index, layout: layout
  end

  def download
    resource = CaseStudy.published.find_by(id: params[:id])
    if resource.present?
      file = resource.t_attached(:file, params[:locale])
      serve_from_storage(file, params[:serve])
    else
      route_not_found
    end
  end
end

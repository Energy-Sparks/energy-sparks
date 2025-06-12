class CaseStudiesController < DownloadableController
  skip_before_action :authenticate_user!

  def index
    @case_studies = CaseStudy.published.order(:position)

    if Flipper.enabled?(:new_case_studies_page, current_user)
      @show_images = @case_studies.without_images.none? || (params[:show_images] && current_user&.admin?)

      if params[:show_images]
        @case_studies = @case_studies.to_a.sort_by do |cs|
          [(cs.image.attached? ? 0 : 1), cs.position]
        end
      end
    end

    render layout: Flipper.enabled?(:new_case_studies_page) ? 'home' : 'application'
  end

  private

  def downloadable_model_class
    CaseStudy
  end

  def file(model)
    model.t_attached(:file, params[:locale])
  end
end

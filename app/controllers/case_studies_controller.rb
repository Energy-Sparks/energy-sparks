class CaseStudiesController < DownloadableController
  skip_before_action :authenticate_user!

  layout 'home'

  def index
    @case_studies = CaseStudy.published.order(:position)

    @show_images = @case_studies.without_images.none? || (params[:show_images] && current_user&.admin?)

    if params[:show_images] && current_user&.admin? # show case studies with images first
      @case_studies = @case_studies.to_a.sort_by do |cs|
        [(cs.image.attached? ? 0 : 1), cs.position]
      end
    end
  end

  private

  def downloadable_model_class
    CaseStudy
  end

  def file(model)
    model.t_attached(:file, params[:locale])
  end
end

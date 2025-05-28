class CaseStudiesController < DownloadableController
  skip_before_action :authenticate_user!
  def index
    @case_studies = CaseStudy.order(position: :asc)
  end

  private

  def downloadable_model_class
    CaseStudy
  end

  def file(model)
    model.t_attached(:file, params[:locale])
  end
end

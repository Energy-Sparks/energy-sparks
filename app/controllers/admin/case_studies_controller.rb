module Admin
  class CaseStudiesController < AdminController
    include LocaleHelper
    load_and_authorize_resource

    before_action :load_case_studies, only: [:index, :show]
    before_action :resize_image, only: [:create, :update]

    def index
    end

    def show
      render :index
    end

    def new
    end

    def edit
    end

    def create
      @case_study = CaseStudy.new(case_study_params.merge(created_by: current_user))
      if @case_study.save
        redirect_to admin_case_study_path(@case_study), notice: 'Case study was successfully created.'
      else
        render :new
      end
    end

    def update
      if @case_study.update(case_study_params.merge(updated_by: current_user))
        redirect_to admin_case_study_path(@case_study), notice: 'Case study was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      @case_study.destroy
      redirect_to admin_case_studies_path, notice: 'Case study was successfully destroyed.'
    end

    private

    def load_case_studies
      @case_studies = CaseStudy.order(:position)
    end

    def case_study_params
      translated_params = t_params(CaseStudy.mobility_attributes + CaseStudy.t_attached_attributes)
      params.require(:case_study).permit(translated_params, :position, :image, :published)
    end

    # Resize image to a max width of 1400px (current max container width) to prevent overly large files
    # and considering future inline use. As it is, these will never be wider than 510px.
    def resize_image
      (image = case_study_params[:image]) || return

      ImageProcessing::MiniMagick
        .source(image)
        .resize_to_limit(1400, nil)
        .call(destination: image.tempfile.path)
    end
  end
end

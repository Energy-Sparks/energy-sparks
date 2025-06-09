module Admin
  class CaseStudiesController < AdminController
    include LocaleHelper
    load_and_authorize_resource

    def index
      @case_studies = CaseStudy.order(:position)
    end

    def show
    end

    def new
    end

    def edit
    end

    def create
      @case_study = CaseStudy.new(case_study_params.merge(created_by: current_user))
      if @case_study.save
        redirect_to admin_case_studies_path, notice: 'Case study was successfully created.'
      else
        render :new
      end
    end

    def update
      if @case_study.update(case_study_params.merge(updated_by: current_user))
        redirect_to admin_case_studies_path, notice: 'Case study was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      @case_study.destroy
      redirect_to admin_case_studies_path, notice: 'Case study was successfully destroyed.'
    end

    private

    def case_study_params
      translated_params = t_params(CaseStudy.mobility_attributes + CaseStudy.t_attached_attributes)
      params.require(:case_study).permit(translated_params, :position, :image, :published)
    end
  end
end

module Schools
  class AlternativeHeatingSourcesController < ApplicationController
    before_action :set_school

    def index
      @school_alternative_heating_sources = @school.school_alternative_heating_sources.all
    end

    def new
    end

    def edit
    end

    def update
      @school.attributes = school_params
      if @school.save
        redirect_to edit_school_alternative_heating_sources_path(@school), notice: 'School alternative heating sources have been updated.'
      else
        render :edit
      end
    end

    # def show
    # end

    private

    def set_school
      @school = School.friendly.find(params[:school_id])
      # authorize! :manage_school_alternative_heating_sources, @school
    end

    def school_params
      params.require(:school).permit(
        school_alternative_heating_sources_attributes: []
      )
    end
  end
end

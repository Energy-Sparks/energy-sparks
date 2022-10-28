module Schools
  class AlternativeHeatingSourcesController < ApplicationController
    before_action :set_school

    def index
      @alternative_heating_sources = @school.alternative_heating_sources.all
    end

    def new
      @alternative_heating_source = @school.alternative_heating_sources.new
    end

    def edit
      @alternative_heating_source = @school.alternative_heating_sources.find(params[:id])
    end

    def create
      @alternative_heating_source = @school.alternative_heating_sources.create!(alternative_heating_source_params)

      if @alternative_heating_source.save
        redirect_to(school_alternative_heating_sources_url(@school.slug), notice: "New alternative heating source was successfully created.")
      else
        render(:new, status: :unprocessable_entity)
      end
    end

    def update
      @alternative_heating_source = @school.alternative_heating_sources.find(params[:id])
      if @alternative_heating_source.update(alternative_heating_source_params)
        redirect_to(school_alternative_heating_sources_url(@school.slug), notice: "Alternative heating source was successfully updated.")
      else
        render(:new, status: :unprocessable_entity)
      end
    end

    def destroy
      if @school.alternative_heating_sources.find(params[:id]).delete
        redirect_to(school_alternative_heating_sources_url(@school.slug), notice: "Alternative heating source was successfully deleted.")
      else
        render(:new, status: :unprocessable_entity)
      end
    end

    private

    def set_school
      @school = School.friendly.find(params[:school_id])
      authorize! :manage_school_alternative_heating_sources, @school
    end

    def alternative_heating_source_params
      params.require(:alternative_heating_source).permit(:source, :percent_of_overall_use, :notes)
    end
  end
end

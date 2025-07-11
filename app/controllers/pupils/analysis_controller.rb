module Pupils
  class AnalysisController < ApplicationController
    load_and_authorize_resource :school

    include SchoolAggregation
    include Measurements

    skip_before_action :authenticate_user!
    before_action :check_aggregated_school_in_cache
    before_action :set_breadcrumbs

    def index
      render fuel_type || :index
    end

    def show
      @chart_type = get_chart_config
      @fuel_type = params.require(:energy)
      @category = get_category
    end

    private

    def fuel_type
      fuel_type = params[:category]
      fuel_type = 'solar' if fuel_type == 'solar_pv'
      fuel_type = 'storage_heaters' if ['storage heaters', 'storage_heater'].include?(fuel_type)
      fuel_type
    end

    def set_breadcrumbs
      @breadcrumbs = [
        { name: I18n.t('dashboards.pupil_dashboard'), href: pupils_school_path(@school) },
        { name: I18n.t('pupils.analysis.explore_data') }
      ]
    end

    # Map the energy names in the URL back to a category
    # These need to be rationalised in the future
    def get_category
      energy = params.require(:energy)
      case energy
      when 'Electricity+Solar PV'
        :solar_pv
      when 'Electricity'
        if @school.has_solar_pv?
          :solar_pv
        else
          :electricity
        end
      else
        energy.downcase.to_sym
      end
    end

    def get_chart_config
      energy = params.require(:energy)
      presentation = params.require(:presentation)
      secondary_presentation = params[:secondary_presentation]

      sub_pages = [energy, presentation, secondary_presentation].compact

      charts = @school.configuration.get_charts(:pupil_analysis_charts, :pupil_analysis_page, *sub_pages)
      chart = charts.first
      raise ActionController::RoutingError.new("Chart for :pupil_analysis_page #{sub_pages.join(' ')} not found") unless chart
      chart
    end
  end
end

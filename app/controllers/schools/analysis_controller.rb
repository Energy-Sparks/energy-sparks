module Schools
  class AnalysisController < ApplicationController
    load_and_authorize_resource :school
    skip_before_action :authenticate_user!

    include SchoolAggregation

    before_action :check_aggregated_school_in_cache, only: :show

    def index
      @heating_pages = process_templates(@school.latest_analysis_pages.heating)
      @electricity_pages = process_templates(@school.latest_analysis_pages.electricity_use)
      @overview_pages = process_templates(@school.latest_analysis_pages.overview)
      @solar_pages = process_templates(@school.latest_analysis_pages.solar_pv)
      @hot_water_pages = process_templates(@school.latest_analysis_pages.hot_water)
      @tariff_pages = process_templates(@school.latest_analysis_pages.tariffs)
      @co2_pages = process_templates(@school.latest_analysis_pages.co2)
      @boiler_control_pages = process_templates(@school.latest_analysis_pages.boiler_control)
      @storage_heater_pages = process_templates(@school.latest_analysis_pages.storage_heaters)
    end

    def show
      @page = @school.analysis_pages.find(params[:id])
      framework_adapter = Alerts::FrameworkAdapter.new(
        alert_type: @page.alert.alert_type,
        school: @school,
        analysis_date: @page.alert.run_on,
        aggregate_school: aggregate_school
      )
      @content = framework_adapter.content
      @title = page_title(@content, @school)
    rescue ActiveRecord::RecordNotFound
      redirect_to school_analysis_path(@school), status: :moved_permanently
    end

  private

    def page_title(content, school)
      title = content.find { |element| element[:type] == :title }
      if title
        title[:content]
      else
        "#{school.name} analysis"
      end
    end

    def process_templates(pages)
      pages.by_priority.map do |page|
        TemplateInterpolation.new(
          page.content_version,
          with_objects: { rating: page.alert.rating, analysis_page: page }
        ).interpolate(
          :analysis_title, :analysis_subtitle,
          with: page.alert.template_variables
        )
      end
    end
  end
end

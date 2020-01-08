module AnalysisPages
  extend ActiveSupport::Concern

  def setup_analysis_pages(analysis_pages)
    @heating_pages = process_analysis_templates(analysis_pages.heating)
    @electricity_pages = process_analysis_templates(analysis_pages.electricity_use)
    @overview_pages = process_analysis_templates(analysis_pages.overview)
    @solar_pages = process_analysis_templates(analysis_pages.solar_pv)
    @hot_water_pages = process_analysis_templates(analysis_pages.hot_water)
    @tariff_pages = process_analysis_templates(analysis_pages.tariffs)
    @co2_pages = process_analysis_templates(analysis_pages.co2)
    @boiler_control_pages = process_analysis_templates(analysis_pages.boiler_control)
    @storage_heater_pages = process_analysis_templates(analysis_pages.storage_heaters)
  end

  def process_analysis_templates(pages)
    pages.by_priority.map do |page|
      TemplateInterpolation.new(
        page.content_version,
        with_objects: {
          rating: page.alert.rating,
          analysis_page: page,
          alert: page.alert,
          priority: page.priority
        }
      ).interpolate(
        :analysis_title, :analysis_subtitle,
        with: page.alert.template_variables
      )
    end
  end
end

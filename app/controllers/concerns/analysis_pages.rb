module AnalysisPages
  extend ActiveSupport::Concern

  def find_analysis_page_of_class(school, analysis_class)
    alert_type = AlertType.where("lower(class_name) = ?", analysis_class.downcase).first
    if alert_type && school.latest_analysis_pages.any?
      school.latest_analysis_pages.includes(:alert).detect { |page| page.alert.alert_type_id == alert_type.id }
    end
  end

  def setup_analysis_pages(analysis_pages)
    @heating_pages = process_analysis_templates(analysis_pages.heating)
    @electricity_pages = process_analysis_templates(analysis_pages.electricity_use)
    @overview_pages = process_analysis_templates(analysis_pages.overview)
    @solar_pages = process_analysis_templates(analysis_pages.solar_pv)
    @hot_water_pages = process_analysis_templates(analysis_pages.hot_water)
    @tariff_pages = process_analysis_templates(analysis_pages.tariffs)
    @co2_pages = setup_co2_pages(analysis_pages)
    @boiler_control_pages = process_analysis_templates(analysis_pages.boiler_control)
    @storage_heater_pages = process_analysis_templates(analysis_pages.storage_heaters)
  end

  def setup_co2_pages(analysis_pages)
    process_analysis_templates(analysis_pages.co2)
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

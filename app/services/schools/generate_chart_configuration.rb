require 'dashboard'

module Schools
  class GenerateChartConfiguration
    def initialize(
        school,
        aggregated_meter_collection,
        fuel_configuration,
        dashboard_fuel_types = DashboardConfiguration::DASHBOARD_FUEL_TYPES,
        dashboard_page_configuration = DashboardConfiguration::DASHBOARD_PAGE_GROUPS
      )
      @school = school
      @aggregated_meter_collection = aggregated_meter_collection
      @fuel_configuration = fuel_configuration
      @dashboard_fuel_types = dashboard_fuel_types
      @dashboard_page_configuration = dashboard_page_configuration
    end

    def generate
      if @fuel_configuration.no_meters_with_validated_readings
        Rails.logger.info "No readings for #{@school.name}, so no configuration"
        return
      end

      Rails.logger.info "Generating chart configuration for #{@school.name} - using default values"
      page_and_chart_config = {}
      pages.each do |page|
        page_and_chart_config[page.to_sym] = page_config(page)
      end
      @school.configuration.update!(analysis_charts: page_and_chart_config)
    end

  private

    def _remove?(chart_type, chart_config = { y_axis_units: :kwh })
      output = ChartData.new(@aggregated_meter_collection, chart_type, false, chart_config).data
      output.first.series_data.nil?
    rescue EnergySparksNotEnoughDataException
      true
    rescue => exception
      Rails.logger.error "Chart generation failed unexpectedly for #{chart_type} and #{@school.name} - #{exception.message}"
      true
    end

    def pages
      @dashboard_fuel_types[@fuel_configuration.fuel_types_for_analysis]
    end

    def title(page)
      @dashboard_page_configuration[page.to_sym][:name]
    end

    def charts(page)
      @dashboard_page_configuration[page.to_sym][:charts]
    end

    def page_config(page)
      @dashboard_page_configuration[page.to_sym]
    end
  end
end

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
        white_listed_page_config = white_listed_page_config(page)
        page_and_chart_config[page.to_sym] = white_listed_page_config unless white_listed_page_config[:charts].empty?
      end
      @school.configuration.update!(analysis_charts: page_and_chart_config)
    end

  private

    def white_listed_page_config(page)
      page_configuration = page_config(page)
      list_of_charts = page_configuration[:charts]
      list_of_charts = list_of_charts.select { |chart| keep?(chart) }
      { name: page_configuration[:name], charts: list_of_charts }
    end

    def keep?(chart_type, chart_config = { y_axis_units: :kwh })
      ChartData.new(@aggregated_meter_collection, chart_type, false, chart_config).success?
    rescue EnergySparksNotEnoughDataException
      false
    rescue => exception
      Rails.logger.error "Chart generation failed unexpectedly for #{chart_type} and #{@school.name} - #{exception.message}"
      false
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

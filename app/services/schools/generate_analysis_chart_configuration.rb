require 'dashboard'

module Schools
  class GenerateAnalysisChartConfiguration
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

    def generate(pages = pages_from_fuel_types)
      if @fuel_configuration.no_meters_with_validated_readings
        Rails.logger.info "No readings for #{@school.name}, so no configuration"
        return {}
      end

      Rails.logger.info "Generating chart configuration for #{@school.name} - using default values"
      page_and_chart_config = {}
      pages.each do |page|
        page_configuration = page_config(page)
        white_listed_page_config = white_listed_page_config(page_configuration)
        page_and_chart_config[page.to_sym] = white_listed_page_config unless empty?(white_listed_page_config)
      end
      page_and_chart_config
    end

  private

    def white_listed_page_config(page_configuration)
      if page_configuration.key?(:sub_pages)
        white_listed_sub_pages = page_configuration[:sub_pages].map do |sub_page|
          white_listed_page_config(sub_page)
        end
        non_empty_sub_pages = white_listed_sub_pages.reject {|sub_page| empty?(sub_page)}
        { name: page_configuration[:name], sub_pages: non_empty_sub_pages }
      else
        list_of_charts = page_configuration[:charts]
        list_of_charts = list_of_charts.select { |chart| keep?(chart) }
        { name: page_configuration[:name], charts: list_of_charts }
      end
    end

    def keep?(chart_type, chart_config = { y_axis_units: :kwh })
      ChartData.new(@aggregated_meter_collection, chart_type, chart_config).has_chart_data?
    end

    def pages_from_fuel_types
      @dashboard_fuel_types[@fuel_configuration.fuel_types_for_analysis]
    end

    def page_config(page)
      @dashboard_page_configuration[page.to_sym]
    end

    def empty?(page_configuration)
      if page_configuration.key?(:sub_pages)
        page_configuration[:sub_pages].all? {|sub_page| empty?(sub_page)}
      else
        page_configuration[:charts].empty?
      end
    end
  end
end

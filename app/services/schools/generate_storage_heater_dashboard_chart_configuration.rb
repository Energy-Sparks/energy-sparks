module Schools
  class GenerateStorageHeaterDashboardChartConfiguration
    def initialize(
        school,
        aggregated_meter_collection,
        fuel_configuration
      )
      @school = school
      @aggregated_meter_collection = aggregated_meter_collection
      @fuel_configuration = fuel_configuration
    end

    def generate
      return Schools::Configuration::NO_STORAGE_HEATER_CHART unless @fuel_configuration.has_storage_heaters
      chart_config = { y_axis_units: :kwh }
      working_chart = charts_in_order_of_more_data_to_no_data.find do |chart_type|
        ChartData.new(@aggregated_meter_collection, chart_type, chart_config).has_chart_data?
      end
      working_chart || Schools::Configuration::NO_STORAGE_HEATER_CHART
    end

  private

    def charts_in_order_of_more_data_to_no_data
      Schools::Configuration.storage_heater_dashboard_chart_types.keys.reverse.map(&:to_sym)
    end
  end
end

module Schools
  class GenerateDashboardChartConfiguration
    def initialize(school, aggregated_meter_collection, fuel_configuration)
      @school = school
      @aggregated_meter_collection = aggregated_meter_collection
      @fuel_configuration = fuel_configuration
    end

    def generate
      charts = []
      charts << chart_type(:electricity) if can_show_electricity?
      charts << chart_type(:gas) if can_show_gas?
      charts << chart_type(:storage_heaters) if can_show_storage_heaters?
      charts << chart_type(:solar_pv) if can_show_solar_pv?
      charts
    end

    private

    def can_show_electricity?
      @fuel_configuration.has_electricity && can_run_chart?(chart_type(:electricity))
    end

    def can_show_gas?
      @fuel_configuration.has_gas && can_run_chart?(chart_type(:gas))
    end

    def can_show_storage_heaters?
      @fuel_configuration.has_storage_heaters && can_run_chart?(chart_type(:storage_heaters))
    end

    def can_show_solar_pv?
      @fuel_configuration.has_solar_pv && can_run_chart?(chart_type(:solar_pv))
    end

    def chart_type(fuel_type)
      Schools::Configuration::MANAGEMENT_DASHBOARD_CHARTS[fuel_type]
    end

    def run_chart(chart_type)
      # This and the can_run_chart? method below confirms whether a given chart can run for a school, which is
      # recorded as part of the overnight run and used to populate the adult dashboard charts.
      # We therefore mark reraise exception false here (used by ChartManager#run_chart) as we don't want to log
      # errors unnecessarily.
      chart_config = { y_axis_units: :kwh }
      ChartData.new(@school, @aggregated_meter_collection, chart_type, chart_config, reraise_exception: false)
    end

    def can_run_chart?(chart_type)
      run_chart(chart_type).has_chart_data?
    end
  end
end

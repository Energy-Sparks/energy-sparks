module Schools
  class GenerateConfiguration
    def initialize(school)
      @school = school
      @aggregated_meter_collection = AggregateSchoolService.new(school).aggregate_school
    end

    def generate
      configuration = Schools::Configuration.where(school: @school).first_or_create

      fuel_configuration = GenerateFuelConfiguration.new(@school).generate
      analysis_chart_configuration = GenerateAnalysisChartConfiguration.new(@school, @aggregated_meter_collection, fuel_configuration).generate
      gas_dashboard_chart_type = GenerateGasDashboardChartConfiguration.new(@school, @aggregated_meter_collection, fuel_configuration).generate

      configuration.update!(
        gas: fuel_configuration.has_gas,
        electricity: fuel_configuration.has_electricity,
        gas_dashboard_chart_type: gas_dashboard_chart_type,
        analysis_charts: analysis_chart_configuration
      )

      configuration
    end
  end
end

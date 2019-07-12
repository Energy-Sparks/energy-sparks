module Schools
  class GenerateConfiguration
    def initialize(school)
      @school = school
      @aggregated_meter_collection = AggregateSchoolService.new(school).aggregate_school
    end

    def generate
      configuration = Schools::Configuration.where(school: @school).first_or_create

      fuel_configuration = GenerateFuelConfiguration.new(@school, configuration).generate
      GenerateAnalysisChartConfiguration.new(@school, @aggregated_meter_collection, fuel_configuration).generate
      GenerateGasDashboardChartConfiguration.new(@school, @aggregated_meter_collection, fuel_configuration).generate
    end
  end
end

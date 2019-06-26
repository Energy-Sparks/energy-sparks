module Schools
  class GenerateConfiguration
    def initialize(school)
      @school = school
      @aggregated_meter_collection = AggregateSchoolService.new(school).aggregate_school
    end

    def generate
      Schools::Configuration.create(school: @school) unless @school.configuration

      fuel_configuration = GenerateFuelConfiguration.new(@school).generate
      GenerateChartConfiguration.new(@school, @aggregated_meter_collection, fuel_configuration).generate
    end
  end
end

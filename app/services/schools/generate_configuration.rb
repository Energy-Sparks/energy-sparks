module Schools
  class GenerateConfiguration
    def initialize(school, aggregate_school = AggregateSchoolService.new(school).aggregate_school)
      @school = school
      @meter_collection = aggregate_school
    end

    def generate
      @school.build_configuration unless @school.configuration
      configuration = @school.configuration

      fuel_configuration = GenerateFuelConfiguration.new(@meter_collection).generate
      aggregate_meter_dates = GenerateMeterDates.new(@meter_collection).generate
      dashboard_charts = GenerateDashboardChartConfiguration.new(@school, @meter_collection,
                                                                 fuel_configuration).generate
      analysis_chart_configuration = GenerateAnalysisChartConfiguration.new(@school, @meter_collection,
                                                                            fuel_configuration)
      pupil_analysis_charts = analysis_chart_configuration.generate([:pupil_analysis_page])
      # should come after fuel_configuration
      school_target_fuel_types = Targets::GenerateFuelTypes.new(@school, @meter_collection).fuel_types_with_enough_data

      configuration.update!({
                              fuel_configuration:,
                              aggregate_meter_dates:,
                              dashboard_charts:,
                              analysis_charts: {},
                              pupil_analysis_charts:,
                              school_target_fuel_types:
                            })

      configuration
    end
  end
end

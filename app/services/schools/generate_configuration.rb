module Schools
  class GenerateConfiguration
    def initialize(school, aggregate_school = AggregateSchoolService.new(school).aggregate_school)
      @school = school
      @aggregated_meter_collection = aggregate_school
    end

    def generate
      @school.build_configuration unless @school.configuration
      configuration = @school.configuration

      fuel_configuration = GenerateFuelConfiguration.new(@aggregated_meter_collection).generate
      configuration.update!(fuel_configuration: fuel_configuration)

      aggregate_meter_dates = GenerateMeterDates.new(@aggregated_meter_collection).generate
      configuration.update!(aggregate_meter_dates: aggregate_meter_dates)

      analysis_chart_configuration = GenerateAnalysisChartConfiguration.new(@school, @aggregated_meter_collection, fuel_configuration)

      analysis_charts = analysis_chart_configuration.generate
      configuration.update!(analysis_charts: analysis_charts)

      pupil_analysis_charts = analysis_chart_configuration.generate([:pupil_analysis_page])
      configuration.update!(pupil_analysis_charts: pupil_analysis_charts)

      #should come after fuel_configuration
      school_target_fuel_types = Targets::GenerateFuelTypes.new(@school, @aggregated_meter_collection).fuel_types_with_enough_data
      configuration.update!(school_target_fuel_types: school_target_fuel_types)

      suggest_estimates_fuel_types = Targets::GenerateFuelTypes.new(@school, @aggregated_meter_collection).suggest_estimates_for_fuel_types
      configuration.update!(suggest_estimates_fuel_types: suggest_estimates_fuel_types)

      estimated_consumption = Targets::GenerateEstimatedUsage.new(@school, @aggregated_meter_collection).generate
      configuration.update!(estimated_consumption: estimated_consumption)

      configuration
    end
  end
end

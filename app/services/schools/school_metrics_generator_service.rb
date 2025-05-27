module Schools
  class SchoolMetricsGeneratorService
    def initialize(school:, meter_collection:, logger: Rails.logger)
      @school = school
      @meter_collection = meter_collection
      @logger = logger
    end

    def perform
      generate_metrics
    end

    private

    def generate_metrics
      # Configuration school
      Schools::GenerateConfiguration.new(@school, @meter_collection).generate
      @logger.info 'Generated configuration'

      # Generate alerts & benchmarks
      Alerts::GenerateAndSaveAlertsAndBenchmarks.new(school: @school, aggregate_school: @meter_collection).perform
      @logger.info 'Generated alerts & benchmarks'

      # Generate equivalences
      Equivalences::GenerateEquivalences.new(school: @school, aggregate_school: @meter_collection).perform
      @logger.info 'Generated equivalences'

      # Generate content
      Alerts::GenerateContent.new(@school).perform
      @logger.info 'Generated alert content'

      # Generate target progress
      Targets::GenerateProgressService.new(@school, @meter_collection).generate!
      @logger.info 'Generated target data'

      # Generate advice page benchmarks
      Schools::AdvicePageBenchmarks::GenerateBenchmarks.new(school: @school, aggregate_school: @meter_collection).generate!
      @logger.info 'Generated advice page benchmarks'

      MeterMonthlySummary.create_or_update_from_school(@school, @meter_collection)
    rescue => e
      @logger.error "There was an error for #{@school.name} - #{e.message}"
      Rollbar.error(e, job: :school_metric_generator, school_id: @school.id, school: @school.name)
    end
  end
end

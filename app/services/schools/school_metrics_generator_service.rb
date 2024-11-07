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
      suppress_output { Schools::GenerateConfiguration.new(@school, @meter_collection).generate }

      @logger.info 'Generated configuration'

      # Generate alerts & benchmarks
      suppress_output do
        Alerts::GenerateAndSaveAlertsAndBenchmarks.new(
          school: @school,
          aggregate_school: @meter_collection
        ).perform
      end
      @logger.info 'Generated alerts & benchmarks'

      # Generate equivalences
      suppress_output { Equivalences::GenerateEquivalences.new(school: @school, aggregate_school: @meter_collection).perform }

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
    rescue => e
      @logger.error "There was an error for #{@school.name} - #{e.message}"
      Rollbar.error(e, job: :school_metric_generator, school_id: @school.id, school: @school.name)
    end

    def suppress_output(&block)
      if Rails.env.production?
        _suppress_output(&block)
      else
        yield
      end
    end

    def _suppress_output
      original_stdout = $stdout.clone
      original_stderr = $stderr.clone
      $stderr.reopen File.new('/dev/null', 'w')
      $stdout.reopen File.new('/dev/null', 'w')
      yield
    ensure
      $stdout.reopen original_stdout
      $stderr.reopen original_stderr
    end
  end
end

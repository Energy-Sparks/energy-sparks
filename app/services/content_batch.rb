class ContentBatch
  def initialize(schools = School.process_data, logger = Rails.logger)
    @schools = schools
    @logger = logger
  end

  def generate
    @benchmark_result_generation_run = BenchmarkResultGenerationRun.create!
    generate_content(@benchmark_result_generation_run)
  end

  def regenerate
    @benchmark_result_generation_run = BenchmarkResultGenerationRun.latest
    generate_content(@benchmark_result_generation_run)
  end

  private

  def generate_content(benchmark_result_generation_run)
    @schools.each do |school|
      @logger.info "Running for #{school.name}"
      puts "Running for #{school.name}"

      # Aggregate school
      aggregate_school = AggregateSchoolService.new(school).aggregate_school

      @logger.info "Aggregated school"

      # Configuration school
      suppress_output { Schools::GenerateConfiguration.new(school, aggregate_school).generate }

      @logger.info "Generated configuration"

      # Generate alerts
      suppress_output { Alerts::GenerateAndSaveAlerts.new(school: school, aggregate_school: aggregate_school).perform }

      @logger.info "Generated alerts"

      # Generate benchmarks
      suppress_output { Alerts::GenerateAndSaveBenchmarks.new(school: school, aggregate_school: aggregate_school, benchmark_result_generation_run: benchmark_result_generation_run).perform }

      @logger.info "Generated benchmaks"

      # Generate equivalences
      suppress_output { Equivalences::GenerateEquivalences.new(school: school, aggregate_school: aggregate_school).perform }

      @logger.info "Generated equivalences"

      # Generate content
      Alerts::GenerateContent.new(school).perform

      @logger.info "Generated alert content"

    rescue StandardError => e
      @logger.error "There was an error for #{school.name} - #{e.message}"
      Rollbar.error(e, school_id: school.id, school_name: school.name)
    end
  end

  def suppress_output
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

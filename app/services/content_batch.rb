class ContentBatch
  def initialize(schools = School.process_data)
    @schools = schools
  end

  def generate
    @benchmark_result_generation_run = BenchmarkResultGenerationRun.create!

    @schools.each do |school|
      Rails.logger.info "Running for #{school.name}"
      puts "Running for #{school.name}"
      # Aggregate school
      aggregate_school = AggregateSchoolService.new(school).aggregate_school

      Rails.logger.info "Aggregated school"

      # Configuration school
      suppress_output { Schools::GenerateConfiguration.new(school, aggregate_school).generate }

      Rails.logger.info "Generated configuration"

      # Generate alerts
      suppress_output { Alerts::GenerateAndSaveAlerts.new(school: school, aggregate_school: aggregate_school).perform }

      Rails.logger.info "Generated alerts"

      # Generate benchmarks
      suppress_output { Alerts::GenerateAndSaveBenchmarks.new(school: school, aggregate_school: aggregate_school, benchmark_result_generation_run: @benchmark_result_generation_run).perform }

      Rails.logger.info "Generated benchmaks"

      # Generate equivalences
      suppress_output { Equivalences::GenerateEquivalences.new(school: school, aggregate_school: aggregate_school).perform }

      Rails.logger.info "Generated equivalences"

      # Generate content
      Alerts::GenerateContent.new(school).perform

      Rails.logger.info "Generated alert content"

      #Rails.logger.info "Generated content"

      begin
        AggregateSchoolService.save_to_s3(aggregate_school, bucket: ENV['AGGREGATE_SCHOOL_CACHE_BUCKET']) if ENV['AGGREGATE_SCHOOL_CACHE_BUCKET'].present?
      rescue => e
        Rails.logger.error "Cannot save aggregate school #{school.name}: #{e.message}"
      end
    end
  end

  private

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

class GenerateBenchmarks
  def initialize(schools = School.process_data)
    @schools = schools
  end

  def generate
    @schools.each do |school|
      Rails.logger.info "Running for #{school.name}"
      puts "Running for #{school.name}"
      # Aggregate school
      aggregate_school = AggregateSchoolService.new(school).aggregate_school

      Rails.logger.info "Aggregated school"

      # Generate benchmarks
      suppress_output { Alerts::GenerateAndSaveBenchmarks.new(school: school, aggregate_school: aggregate_school).perform }

      Rails.logger.info "Generated benchmaks"
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

class ContentBatch
  def initialize(schools = School.process_data)
    @schools = schools
  end

  def generate
    @schools.each do |school|
      Rails.logger.info "Running for #{school.name}"
      # Aggregate school
      aggregate_school = AggregateSchoolService.new(school).aggregate_school

      Rails.logger.info "Aggregated school"

      # Configuration school
      suppress_output { Schools::GenerateConfiguration.new(school, aggregate_school).generate }

      Rails.logger.info "Generated configuration"

      # Generate alerts
      suppress_output { Alerts::GenerateAndSaveAlertsAndBenchmarks.new(school: school, aggregate_school: aggregate_school).perform }

      Rails.logger.info "Generated alerts"

      # Generate equivalences
      suppress_output { Equivalences::GenerateEquivalences.new(school: school, aggregate_school: aggregate_school).perform }

      Rails.logger.info "Generated equivalences"

      # Generate content
      Alerts::GenerateContent.new(school).perform

      Rails.logger.info "Generated alert content"

      Rails.logger.info "Generated content"
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

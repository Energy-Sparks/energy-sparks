class SchoolContentBatchJob < ApplicationJob
  self.queue_adapter = :delayed_job
  queue_as :school_content_batches

  def perform(school:, benchmark_result_generation_run:)
    aggregate_school = AggregateSchoolService.new(school).aggregate_school
    Schools::GenerateConfiguration.new(school, aggregate_school).generate
    Alerts::GenerateAndSaveAlerts.new(school: school, aggregate_school: aggregate_school).perform
    Alerts::GenerateAndSaveBenchmarks.new(school: school, aggregate_school: aggregate_school, benchmark_result_generation_run: benchmark_result_generation_run).perform
    Equivalences::GenerateEquivalences.new(school: school, aggregate_school: aggregate_school).perform
    Alerts::GenerateContent.new(school).perform
    Targets::GenerateProgressService.new(school, aggregate_school).generate!
  end
end

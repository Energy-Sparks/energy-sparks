class SchoolContentBatchJob < ApplicationJob
  self.queue_adapter = :good_job
  queue_as :school_content_batches

  def perform(school:, benchmark_result_generation_run:)
    aggregate_school = AggregateSchoolService.new(school).aggregate_school
    Schools::GenerateConfiguration.new(school, aggregate_school).generate
    Alerts::GenerateAndSaveAlerts.new(school: school, aggregate_school: aggregate_school).perform
    Alerts::GenerateAndSaveBenchmarks.new(school: school, aggregate_school: aggregate_school, benchmark_result_generation_run: benchmark_result_generation_run).perform
    Equivalences::GenerateEquivalences.new(school: school, aggregate_school: aggregate_school).perform
    Alerts::GenerateContent.new(school).perform
    Targets::GenerateProgressService.new(school, aggregate_school).generate!

    school_target = school.most_recent_target
    school_target.update(report_last_generated: Time.zone.now) if school_target.present?
  end
end

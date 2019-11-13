module Alerts
  class GenerateAndSaveAlertsAndBenchmarks
    def initialize(school:, aggregate_school: AggregateSchoolService.new(school).aggregate_school)
      @school = school
      @aggregate_school = aggregate_school
    end

    def perform
      @alert_generation_run = AlertGenerationRun.create!(school: @school)

      alerts_to_save = []
      alert_errors_to_save = []
      benchmark_results_to_save = []

      alert_reports = GenerateAlertReports.new(school: @school, aggregate_school: @aggregate_school, alert_generation_run_id: @alert_generation_run.id).perform

      if alert_reports.any?
        alert_reports.each do |alert_report|
          if alert_report.valid
            alerts_to_save << AlertAttributesFactory.new(@school, alert_report, @alert_generation_run.id).generate
            if alert_report.benchmark_data.present?
              benchmark_results_to_save << BenchmarkAttributesFactory.new(alert_report, @alert_generation_run.id).generate
            end
          else
            alert_errors_to_save << ErrorAttributesFactory.new(alert_report.alert_type, alert_report.asof_date, "Relevance: #{alert_report.relevance}", @alert_generation_run.id).generate
          end
        end
      end

      Alert.insert_all!(alerts_to_save) unless alerts_to_save.empty?
      AlertError.insert_all!(alert_errors_to_save) unless alert_errors_to_save.empty?
      BenchmarkResult.insert_all!(benchmark_results_to_save) unless benchmark_results_to_save.empty?
    end
  end
end

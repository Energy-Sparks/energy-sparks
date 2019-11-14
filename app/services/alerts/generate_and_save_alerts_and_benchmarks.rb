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

      alert_type_run_results = GenerateAlertReports.new(school: @school, aggregate_school: @aggregate_school).perform

      if alert_type_run_results.any?
        alert_type_run_results.each do |alert_type_run_result|
          process_alert_type_run_result(alert_type_run_result, alerts_to_save, alert_errors_to_save, benchmark_results_to_save)
        end
      end

      Alert.insert_all!(alerts_to_save) unless alerts_to_save.empty?
      AlertError.insert_all!(alert_errors_to_save) unless alert_errors_to_save.empty?
      BenchmarkResult.insert_all!(benchmark_results_to_save) unless benchmark_results_to_save.empty?
    end

    private

    def process_alert_type_run_result(alert_type_run_result, alerts_to_save, alert_errors_to_save, benchmark_results_to_save)
      alert_type = alert_type_run_result.alert_type
      error_attributes_list = alert_type_run_result.error_attributes
      reports = alert_type_run_result.reports

      error_attributes_list.each do |error_attributes|
        error_attributes[:alert_generation_run_id] = @alert_generation_run.id
        alert_errors_to_save << error_attributes
      end

      reports.each do |alert_report|
        process_alert_report(alert_type, alert_report, alerts_to_save, alert_errors_to_save, benchmark_results_to_save)
      end
    end

    def process_alert_report(alert_type, alert_report, alerts_to_save, alert_errors_to_save, benchmark_results_to_save)
      if alert_report.valid
        alerts_to_save << AlertAttributesFactory.new(@school, alert_report, @alert_generation_run, alert_type).generate
        if alert_report.benchmark_data.present?
          benchmark_results_to_save << BenchmarkAttributesFactory.new(alert_report, @alert_generation_run, alert_type).generate
        end
      else
        alert_errors_to_save << ErrorAttributesFactory.new(alert_type, alert_report.asof_date, "Relevance: #{alert_report.relevance}", @alert_generation_run).generate
      end
    end
  end
end

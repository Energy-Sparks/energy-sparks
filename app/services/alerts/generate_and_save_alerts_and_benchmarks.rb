module Alerts
  class GenerateAndSaveAlertsAndBenchmarks
    def initialize(school:, aggregate_school: AggregateSchoolService.new(school).aggregate_school)
      @school = school
      @aggregate_school = aggregate_school
    end

    def perform
      ActiveRecord::Base.transaction do
        @alert_generation_run = AlertGenerationRun.create!(school: @school)

        alert_type_run_results = GenerateAlertReports.new(school: @school, aggregate_school: @aggregate_school).perform

        alert_type_run_results.each do |alert_type_run_result|
          process_alert_type_run_result(alert_type_run_result)
        end
      end
    end

    private

    def process_alert_type_run_result(alert_type_run_result)
      asof_date = alert_type_run_result.asof_date
      alert_type = alert_type_run_result.alert_type

      alert_type_run_result.error_messages.each do |error_message|
        AlertError.create!(alert_generation_run: @alert_generation_run, asof_date: asof_date, information: error_message, alert_type: alert_type)
      end

      alert_type_run_result.reports.each do |alert_report|
        process_alert_report(alert_type, alert_report, asof_date)
      end
    end

    def process_alert_report(alert_type, alert_report, asof_date)
      if alert_report.valid
        Alert.create(AlertAttributesFactory.new(@school, alert_report, @alert_generation_run, alert_type).generate)
        if alert_report.benchmark_data.present?
          BenchmarkResult.create!(alert_generation_run: @alert_generation_run, asof: alert_report.asof_date, alert_type: alert_type, data: alert_report.benchmark_data)
        end
      else
        AlertError.create!(alert_generation_run: @alert_generation_run, asof_date: asof_date, information: "Relevance: #{alert_report.relevance}", alert_type: alert_type)
      end
    end
  end
end

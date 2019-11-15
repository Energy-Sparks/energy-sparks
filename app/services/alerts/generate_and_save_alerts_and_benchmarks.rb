module Alerts
  class GenerateAndSaveAlertsAndBenchmarks
    def initialize(school:, aggregate_school: AggregateSchoolService.new(school).aggregate_school)
      @school = school
      @aggregate_school = aggregate_school
      @save_alerts = true
    end

    def perform
      generate_and_process_alerts_and_benchmarks
    end

    def perform_benchmarks_only(asof_date)
      generate_and_process_alerts_and_benchmarks(sources: [:analytics], asof_date: asof_date, save_alerts: false)
    end

    private

    def generate_and_process_alerts_and_benchmarks(sources: AlertType.sources, asof_date: nil, save_alerts: true)
      alert_types = relevant_alert_types(sources: sources)

      ActiveRecord::Base.transaction do
        @alert_generation_run = AlertGenerationRun.create!(school: @school)

        alert_type_run_results = GenerateAlertReports.new(school: @school, aggregate_school: @aggregate_school, alert_types: alert_types, asof_date: asof_date).perform

        alert_type_run_results.each do |alert_type_run_result|
          process_alert_type_run_result(alert_type_run_result, save_alerts)
        end
      end
    end

    def relevant_alert_types(sources:)
      RelevantAlertTypes.new(@school).list(sources: sources)
    end

    def process_alert_type_run_result(alert_type_run_result, save_alerts)
      asof_date = alert_type_run_result.asof_date
      alert_type = alert_type_run_result.alert_type

      alert_type_run_result.error_messages.each do |error_message|
        AlertError.create!(alert_generation_run: @alert_generation_run, asof_date: asof_date, information: error_message, alert_type: alert_type)
      end

      alert_type_run_result.reports.each do |alert_report|
        process_alert_report(alert_type, alert_report, asof_date, save_alerts)
      end
    end

    def process_alert_report(alert_type, alert_report, asof_date, save_alerts)
      if alert_report.valid
        Alert.create(AlertAttributesFactory.new(@school, alert_report, @alert_generation_run, alert_type).generate) if save_alerts
        if alert_report.benchmark_data.present?
          BenchmarkResult.create!(alert_generation_run: @alert_generation_run, asof: asof_date, alert_type: alert_type, data: alert_report.benchmark_data)
        end
      else
        AlertError.create!(alert_generation_run: @alert_generation_run, asof_date: asof_date, information: "Relevance: #{alert_report.relevance}", alert_type: alert_type)
      end
    end
  end
end

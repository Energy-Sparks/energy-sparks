module Alerts
  class GenerateAndSaveBenchmarks
    def initialize(
        school:,
        aggregate_school: AggregateSchoolService.new(school).aggregate_school,
        asof_date: Time.zone.today,
        framework_adapter: FrameworkAdapter
        )
      @school = school
      @aggregate_school = aggregate_school
      @asof_date = asof_date
      @framework_adapter = framework_adapter
    end

    def perform
      ActiveRecord::Base.transaction do
        @benchmark_result_generation_run = BenchmarkResultGenerationRun.create!(school: @school)

        relevant_alert_types.each do |alert_type|
          benchmark_dates(alert_type).each do |benchmark_date|
            alert_type_run_result = GenerateAlertTypeRunResult.new(school: @school, aggregate_school: @aggregate_school, alert_type: alert_type, asof_date: benchmark_date).perform
            process_alert_type_run_result(alert_type_run_result)
          end
        end
      end
    end

    private

    def benchmark_dates(alert_type)
      @framework_adapter.new(alert_type: alert_type, school: @school, analysis_date: @asof_date, aggregate_school: @aggregate_school).benchmark_dates
    end

    def relevant_alert_types
      RelevantAlertTypes.new(@school).list.select { |alert_type| alert_type.source.to_sym == :analytics && ! alert_type.background }
    end

    def process_alert_type_run_result(alert_type_run_result)
      asof_date = alert_type_run_result.asof_date
      alert_type = alert_type_run_result.alert_type

      alert_type_run_result.error_messages.each do |error_message|
        BenchmarkResultError.create!(benchmark_result_generation_run: @benchmark_result_generation_run, asof_date: asof_date, information: error_message, alert_type: alert_type)
      end

      alert_type_run_result.reports.each do |alert_report|
        process_alert_report(alert_type, alert_report, asof_date)
      end
    end

    def process_alert_report(alert_type, alert_report, asof_date)
      if alert_report.valid
        if alert_report.benchmark_data.present?
          BenchmarkResult.create!(benchmark_result_generation_run: @benchmark_result_generation_run, asof: asof_date, alert_type: alert_type, data: alert_report.benchmark_data)
        end
      else
        BenchmarkResultError.create!(benchmark_result_generation_run: @benchmark_result_generation_run, asof_date: asof_date, information: "Relevance: #{alert_report.relevance}", alert_type: alert_type)
      end
    end
  end
end

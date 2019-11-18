module Alerts
  class GenerateAndSaveBenchmarks
    def initialize(
        school:,
        aggregate_school: AggregateSchoolService.new(school).aggregate_school,
        framework_adapter: FrameworkAdapter
        )
      @school = school
      @aggregate_school = aggregate_school
      @framework_adapter = framework_adapter
    end

    def perform(asof_date = Time.zone.today)
      ActiveRecord::Base.transaction do
        @benchmark_result_generation_run = BenchmarkResultGenerationRun.create!(school: @school)

        relevant_alert_types.each do |alert_type|
          service = GenerateAlertTypeRunResult.new(school: @school, aggregate_school: @aggregate_school, alert_type: alert_type)
          service.benchmark_dates(asof_date).each do |benchmark_date|
            alert_type_run_result = service.perform(benchmark_date)
            process_alert_type_run_result(alert_type_run_result)
          end
        end
      end
    end

    private

    def relevant_alert_types
      RelevantAlertTypes.new(@school).list.select(&:benchmark)
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

module Alerts
  class GenerateAndSaveBenchmarks
    def initialize(school:, aggregate_school: AggregateSchoolService.new(school).aggregate_school, asof_date: Time.zone.today)
      @school = school
      @aggregate_school = aggregate_school
      @asof_date = asof_date
    end

    def perform
      ActiveRecord::Base.transaction do
        @benchmark_result_generation_run = BenchmarkResultGenerationRun.create!(school: @school)

        relevant_alert_types.each do |alert_type|
          benchmark_dates(alert_type, @asof_date).each do |benchmark_date|
            alert_type_run_result = GenerateAlertTypeRunResult.new(school: @school, aggregate_school: @aggregate_school, alert_type: alert_type, asof_date: benchmark_date).perform
            process_alert_type_run_result(alert_type_run_result)
          end
        end
      end
    end

    private

    # TODO replace this with the *actual* class call via an adapter
    def benchmark_dates(_alert_type, asof_date)
      [asof_date, asof_date - 1.year]
    end

    def relevant_alert_types
      RelevantAlertTypes.new(@school).list.select { |alert_type| alert_type.source.to_sym == :analytics }
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
      if alert_report.valid && alert_report.benchmark_data.present?
        BenchmarkResult.create!(benchmark_result_generation_run: @benchmark_result_generation_run, asof: asof_date, alert_type: alert_type, data: alert_report.benchmark_data)
      else
        BenchmarkResultError.create!(benchmark_result_generation_run: @benchmark_result_generation_run, asof_date: asof_date, information: "Relevance: #{alert_report.relevance}", alert_type: alert_type)
      end
    end
  end
end

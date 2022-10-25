module Alerts
  class GenerateAndSaveAlertsAndBenchmarks
    def initialize(school:, aggregate_school: nil, benchmark_result_generation_run: nil, framework_adapter: FrameworkAdapter)
      @school = school
      @aggregate_school = aggregate_school || AggregateSchoolService.new(school).aggregate_school
      @benchmark_result_generation_run = benchmark_result_generation_run || BenchmarkResultGenerationRun.create!
      @framework_adapter = framework_adapter
    end

    def perform
      ActiveRecord::Base.transaction do
        @alert_generation_run = AlertGenerationRun.create!(school: @school)
        @benchmark_result_school_generation_run = BenchmarkResultSchoolGenerationRun.create!(school: @school, benchmark_result_generation_run: @benchmark_result_generation_run)

        relevant_alert_types.each do |alert_type|
          service = GenerateAlertTypeRunResult.new(school: @school, aggregate_school: @aggregate_school, alert_type: alert_type, use_max_meter_date_if_less_than_asof_date: true)
          alert_type_run_result = service.perform
          process_alert_type_run_result(alert_type_run_result)
          process_benchmark_type_run_result(alert_type_run_result) if alert_type.benchmark == true
        end
      end
    end

    private

    def process_benchmark_type_run_result(alert_type_run_result)
      asof_date = alert_type_run_result.asof_date
      alert_type = alert_type_run_result.alert_type

      alert_type_run_result.error_messages.each do |error_message|
        BenchmarkResultError.create!(benchmark_result_school_generation_run: @benchmark_result_school_generation_run, asof_date: asof_date, information: error_message, alert_type: alert_type)
      end

      alert_type_run_result.reports.each do |alert_report|
        process_alert_benchmark_report(alert_type, alert_report, asof_date)
      end
    end

    def process_alert_benchmark_report(alert_type, alert_report, asof_date)
      if alert_report.valid
        if alert_report.benchmark_data.present?
          BenchmarkResult.create!(benchmark_result_school_generation_run: @benchmark_result_school_generation_run, asof: asof_date, alert_type: alert_type, data: alert_report.benchmark_data, results: BenchmarkResult.convert_for_storage(alert_report.benchmark_data))
        end
      else
        BenchmarkResultError.create!(benchmark_result_school_generation_run: @benchmark_result_school_generation_run, asof_date: asof_date, information: "Relevance: #{alert_report.relevance}", alert_type: alert_type)
      end
    end

    def relevant_alert_types
      RelevantAlertTypes.new(@school).list
    end

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
        Alert.create(AlertAttributesFactory.new(@school, alert_report, @alert_generation_run, alert_type, asof_date).generate)
      else
        AlertError.create!(alert_generation_run: @alert_generation_run, asof_date: asof_date, information: "INVALID. Relevance: #{alert_report.relevance}", alert_type: alert_type)
      end
    end
  end
end

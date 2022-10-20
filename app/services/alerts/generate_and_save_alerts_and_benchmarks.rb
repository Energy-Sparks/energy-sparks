module Alerts
  class GenerateAndSaveAlertsAndBenchmarks
    def initialize(school:, aggregate_school: nil, benchmark_result_generation_run: nil)
      @school = school
      @aggregate_school = aggregate_school || create_new_aggregate_school_service_for(school)
      @benchmark_result_generation_run = benchmark_result_generation_run || BenchmarkResultGenerationRun.latest
    end

    def perform
      ActiveRecord::Base.transaction do
        create_a_new_school_alert_generation_run
        generate_alert_type_run_results_for_relevant_alert_types
      end
    end

    private

    def create_new_aggregate_school_service_for(school)
      AggregateSchoolService.new(school).aggregate_school
    end

    def generate_alert_type_run_results_for_relevant_alert_types
      find_relevant_alert_types.each do |alert_type|
        if alert_type.benchmark
          generate_alert_type_and_benchmark_run_results_for(alert_type)
        else
          generate_alert_type_run_results_for(alert_type)
        end
      end
    end

    def generate_alert_type_and_benchmark_run_results_for(alert_type)
      asof_date = Time.zone.today # placeholder until we know what to do with asof dates

      service = GenerateAlertTypeRunResult.new(school: @school, aggregate_school: @aggregate_school, alert_type: alert_type, use_max_meter_date_if_less_than_asof_date: true)
      service.benchmark_dates(asof_date).each do |benchmark_date|
        alert_type_run_result = service.perform(benchmark_date)
        process_alert_type_run_result(alert_type_run_result)
      end
    end

    def generate_alert_type_run_results_for(alert_type)
      alert_type_run_result = GenerateAlertTypeRunResult.new(school: @school, aggregate_school: @aggregate_school, alert_type: alert_type).perform

      process_alert_type_run_result(alert_type_run_result)
    end

    def create_a_new_school_alert_generation_run
      @alert_generation_run = AlertGenerationRun.create!(school: @school)
    end

    def find_relevant_alert_types
      Alerts::RelevantAlertTypes.new(@school).list
    end

    def process_alert_type_run_result(alert_type_run_result)
      # Create error messages
      alert_type_run_result.error_messages.each do |error_message|
        create_alert_error_for(alert_type_run_result.asof_date, error_message, alert_type_run_result.alert_type)
      end

      # Process alert type run reports
      alert_type_run_result.reports.each do |alert_report|
        process_alert_report(alert_type_run_result.alert_type, alert_report, alert_type_run_result.asof_date)
      end
    end

    def create_alert_error_for(asof_date, error_message, alert_type)
      AlertError.create!(
        alert_generation_run: @alert_generation_run,
        asof_date: asof_date,
        information: error_message,
        alert_type: alert_type
      )
    end

    def create_alert_for(asof_date, alert_report, alert_type)
      alert_attributes = build_alert_attributes_for(alert_report, alert_type, asof_date)

      Alert.create!(alert_attributes)
    end

    def build_alert_attributes_for(alert_report, alert_type, asof_date)
      AlertAttributesFactory.new(@school, alert_report, @alert_generation_run, alert_type, asof_date).generate
    end

    def process_alert_report(alert_type, alert_report, asof_date)
      if alert_report.valid
        create_alert_for(asof_date, alert_report, alert_type)
      else
        create_alert_error_for(asof_date, "INVALID. Relevance: #{alert_report.relevance}", alert_type)
      end
    end
  end
end

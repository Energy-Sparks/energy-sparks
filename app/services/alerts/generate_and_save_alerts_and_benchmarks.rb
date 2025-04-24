# frozen_string_literal: true

module Alerts
  class GenerateAndSaveAlertsAndBenchmarks
    def initialize(school:, aggregate_school: nil,
                   framework_adapter: FrameworkAdapter)
      @school = school
      @aggregate_school = aggregate_school || AggregateSchoolService.new(school).aggregate_school
      @framework_adapter = framework_adapter
      @configurable_alert_types, @relevant_alert_types = RelevantAlertTypes.new(@school).list.partition do |alert_type|
        [AlertConfigurablePeriodElectricityComparison, AlertConfigurablePeriodGasComparison,
         AlertConfigurablePeriodStorageHeaterComparison].map(&:name).include?(alert_type.class_name)
      end
    end

    def perform
      ActiveRecord::Base.transaction do
        @alert_generation_run = AlertGenerationRun.create!(school: @school)
        @relevant_alert_types.each { |alert_type| process_alert_and_benchmarks_for(alert_type) }
        process_custom_periods
      end
    end

    private

    def process_alert_and_benchmarks_for(alert_type)
      if alert_type.class_name == 'AlertImpendingHoliday'
        # AlertImpendingHoliday is a special case where different asof_date is handled
        # slightly differently
        service = generate_alert_type_run_result_service(
          alert_type: alert_type,
          use_max_meter_date_if_less_than_asof_date: false
        )
        alert_type_run_result = service.perform(Time.zone.today)
        process_alert_type_run_result(alert_type_run_result)
      else
        service = generate_alert_type_run_result_service(
          alert_type: alert_type,
          use_max_meter_date_if_less_than_asof_date: alert_type.fuel_type.present?
        )
        alert_type_run_result = service.perform
        process_alert_type_run_result(alert_type_run_result)
      end
    end

    def generate_alert_type_run_result_service(alert_type:, use_max_meter_date_if_less_than_asof_date:)
      GenerateAlertTypeRunResult.new(
        school: @school,
        aggregate_school: @aggregate_school,
        alert_type: alert_type,
        use_max_meter_date_if_less_than_asof_date: use_max_meter_date_if_less_than_asof_date
      )
    end

    def process_alert_type_run_result(alert_type_run_result, report: nil)
      asof_date = alert_type_run_result.asof_date
      alert_type = alert_type_run_result.alert_type

      alert_type_run_result.error_messages.each do |error_message|
        AlertError.create!(alert_generation_run: @alert_generation_run, asof_date: asof_date,
                           information: error_message, alert_type: alert_type, comparison_report: report)
      end

      alert_type_run_result.reports.each do |alert_report|
        process_alert_report(alert_type, alert_report, asof_date, report)
      end
    end

    def process_alert_report(alert_type, alert_report, asof_date, report)
      if alert_report.valid
        alert_attributes = { comparison_report: report }
        alert_attributes[:reporting_period] = :custom unless report.nil?
        Alert.create(AlertAttributesFactory.new(@school, alert_report, @alert_generation_run, alert_type,
                                                asof_date).generate.merge(**alert_attributes))
      else
        AlertError.create!(alert_generation_run: @alert_generation_run, asof_date: asof_date, comparison_report: report,
                           information: "INVALID. Relevance: #{alert_report.relevance}", alert_type: alert_type)
      end
    end

    def process_custom_periods
      Comparison::Report.where(disabled: false).where.not(custom_period: nil).find_each do |report|
        @configurable_alert_types.each do |alert_type|
          analysis_date = AggregateSchoolService.analysis_date(@aggregate_school, alert_type.fuel_type)
          result = AlertTypeRunResult.generate_alert_report(alert_type, analysis_date, @school) do
            Adapters::AnalyticsAdapter
              .new(alert_type:,
                   analysis_date:,
                   school: @school,
                   aggregate_school: @aggregate_school,
                   use_max_meter_date_if_less_than_asof_date: true)
              .report(alert_configuration: report.to_alert_configuration)
          end
          process_alert_type_run_result(result, report: report)
        end
      end
    end
  end
end

module Alerts
  class GenerateAndSaveAlerts
    def initialize(school:, aggregate_school: AggregateSchoolService.new(school).aggregate_school)
      @school = school
      @aggregate_school = aggregate_school
    end

    def perform
      ActiveRecord::Base.transaction do
        @alert_generation_run = AlertGenerationRun.create!(school: @school)

        relevant_alert_types.each do |alert_type|
          alert_type_run_result = GenerateAlertTypeRunResult.new(school: @school, aggregate_school: @aggregate_school, alert_type: alert_type).perform
          process_alert_type_run_result(alert_type_run_result)
        end
      end
    end

    private

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

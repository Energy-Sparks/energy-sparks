module Alerts
  class GenerateAlertReports
    def initialize(
        school:,
        alert_generation_run_id:,
        framework_adapter: FrameworkAdapter,
        aggregate_school: AggregateSchoolService.new(school).aggregate_school
      )
      @school = school
      @alert_framework_adapter_class = framework_adapter
      @aggregate_school = aggregate_school
      @alert_generation_run_id = alert_generation_run_id
    end

    def perform
      alert_reports = []
      alert_errors_to_save = []

      relevant_alert_types.each do |alert_type|
        alert_reports << generate_alert_report(alert_type, alert_errors_to_save)
      end

      AlertError.insert_all!(alert_errors_to_save) unless alert_errors_to_save.empty?

      alert_reports
    end

    def relevant_alert_types
      alert_types = AlertType.no_fuel
      alert_types = alert_types | AlertType.electricity_fuel_type if @school.has_electricity?
      alert_types = alert_types | AlertType.gas_fuel_type if @school.has_gas?
      alert_types = alert_types | AlertType.storage_heater_fuel_type if @school.has_storage_heaters?
      alert_types = alert_types | AlertType.solar_pv_fuel_type if @school.has_solar_pv?
      alert_types
    end

    private

    def generate_alert_report(alert_type, alert_errors_to_save)
      alert_framework_adapter = @alert_framework_adapter_class.new(alert_type: alert_type, school: @school, aggregate_school: @aggregate_school)
      asof_date = alert_framework_adapter.analysis_date

      alert_framework_adapter.analyse
    rescue => e
      error_message = "Exception: #{alert_type.class_name} for #{@school.name}: #{e.class} #{e.message}"
      Rails.logger.error error_message
      Rails.logger.error e.backtrace.join("\n")
      Rollbar.error(e, school_id: @school.id, school_name: @school.name, alert_type: alert_type.class_name)

      error_message = "#{error_message}\n" + e.backtrace.join("\n")

      alert_errors_to_save << ErrorAttributesFactory.new(alert_type, asof_date, error_message, @alert_generation_run_id).generate
    end
  end
end

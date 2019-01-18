require 'dashboard'

module Alerts
  class BuildAlerts
    def initialize(
      school,
      aggregate_school = AggregateSchoolService.new(school).aggregate_school,
      gas_analysis_date = school.last_reading_date(:gas),
      electricity_analysis_date = school.last_reading_date(:electricity),
      alert_framework_adapter = FrameworkAdapter
    )
      @school = school
      @gas_analysis_date = gas_analysis_date
      @electricity_analysis_date = electricity_analysis_date
      @aggregate_school = aggregate_school
      @alert_framework_adapter = alert_framework_adapter
      @alerts = []
    end

    def perform
      @alerts << run_alerts(AlertType.no_fuel, Time.zone.today)

      if @school.meters_with_readings(:electricity).any?
        @alerts << run_alerts(AlertType.electricity, @electricity_analysis_date)
      end

      if @school.meters_with_readings(:gas).any?
        @alerts << run_alerts(AlertType.gas, @gas_analysis_date)
      end
      @alerts.flatten
    end

  private

    def run_alerts(alert_types, analysis_date)
      alert_types.map do |alert_type|
        alert_framework_instance = @alert_framework_adapter.new(alert_type, @aggregate_school).alert_instance
        alert_framework_instance.analyse(analysis_date)

        Alert.new(
          school_id: @school.id,
          alert_type_id: alert_type.id,
          run_on: analysis_date,
          status: alert_framework_instance.analysis_report.status,
          summary: alert_framework_instance.analysis_report.summary,
          data: data_hash(alert_framework_instance.analysis_report),
        )
      end
    end

    def data_hash(analysis_report)
      {
        help_url: analysis_report.help_url,
        detail: analysis_report.detail,
        rating: analysis_report.rating,
      }
    end
  end
end

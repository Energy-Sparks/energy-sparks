require 'dashboard'
require 'upsert/active_record_upsert'

class GenerateAndPersistAlerts
  def initialize(
    school,
    aggregate_school = AggregateSchoolService.new(school).aggregate_school,
    gas_analysis_date = school.last_reading_date(:gas),
    electricity_analysis_date = school.last_reading_date(:electricity),
    alert_framework_adapter = AlertFrameworkAdapter
  )
    @school = school
    @gas_analysis_date = gas_analysis_date
    @electricity_analysis_date = electricity_analysis_date
    @aggregate_school = aggregate_school
    @alert_framework_adapter = alert_framework_adapter
    @update_create_time = Time.zone.now
  end

  def perform
    run_and_persist_alerts(AlertType.no_fuel, Time.zone.today)

    if @school.meters_with_readings(:electricity).any?
      run_and_persist_alerts(AlertType.electricity, @electricity_analysis_date)
    end

    if @school.meters_with_readings(:gas).any?
      run_and_persist_alerts(AlertType.gas, @gas_analysis_date)
    end
  end

private

  def run_and_persist_alerts(alert_types, analysis_date)
    alert_types.map do |alert_type|
      alert_framework_instance = @alert_framework_adapter.new(alert_type, @aggregate_school).alert_instance
      alert_framework_instance.analyse(analysis_date)

      # to_json is required because upsert supports Hstore but not JSON
      Alert.upsert({ school_id: @school.id, alert_type_id: alert_type.id, run_on: analysis_date },
        status: alert_framework_instance.analysis_report.status,
        summary: alert_framework_instance.analysis_report.summary,
        data: data_hash(alert_framework_instance.analysis_report).to_json,
        updated_at: @update_create_time,
        created_at: @update_create_time)
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

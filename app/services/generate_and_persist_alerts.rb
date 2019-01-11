require 'dashboard'

class GenerateAndPersistAlerts
  def initialize(school, aggregate_school, gas_analysis_date = Time.zone.today, electricity_analysis_date = Time.zone.today, send_sms_service = SendSms)
    @school = school
    @gas_analysis_date = gas_analysis_date
    @electricity_analysis_date = electricity_analysis_date
    @send_sms_service = send_sms_service
    @aggregate_school = aggregate_school
  end

  def perform
    run_and_persist_alerts(AlertType.no_fuel)

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
      alert = alert_type.class_name.constantize.new(@aggregate_school)
      alert.analyse(analysis_date)
      data_hash = {
        help_url: alert.analysis_report.help_url,
        detail: alert.analysis_report.detail,
        rating: alert.analysis_report.rating,
      }
      Alert.create(school: school, alert_type: alert_type, status: alert.analysis_report.status, summary: alert.analysis_report.summary, data: data_hash)
    end
  end
end

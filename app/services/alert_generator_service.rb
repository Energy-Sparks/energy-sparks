require 'dashboard'

class AlertGeneratorService
  def initialize(school, analysis_date = Date.new(2018, 2, 2))
    @school = school
    @analysis_date = analysis_date
  end

  def perform
    return [] unless @school.alerts?
    @results = AlertType.all.map do |alert_type|
      alert = alert_type.class_name.constantize.new(aggregate_school)
      alert.analyse(@analysis_date)
      { report: alert.analysis_report, title: alert_type.title, description: alert_type.description }
    end
  end

  def generate_for_contacts
    return if @school.contacts.empty?

    @school.contacts.each do |contact|
      alerts_for_contact = get_alerts(contact)
      process_alerts_for_contact(contact, alerts_for_contact)
    end
  end

private

  def process_alerts_for_contact(contact, alerts)
    if contact.email_address?
      AlertMailer.with(email_address: contact.email_address, alerts: alerts, school: @school).alert_email.deliver_now
    end

    if contact.mobile_phone_number?
      logger.info "Send SMS message"
    end
  end

  # Get array of alerts for this contact
  def get_alerts(contact)
    contact.alerts.map do |alert|
      next unless run_this_alert?(alert)
      alert_type_class = alert.alert_type_class
      alert_object = alert_type_class.new(aggregate_school)
      alert_object.analyse(@analysis_date)
      { analysis_report: alert_object.analysis_report, title: alert.title, description: alert.description }
    end
  end

  def run_this_alert?(alert)
    alert_type = alert.alert_type
    if alert_type.before_each_holiday? && @school.holiday_approaching?
      return true
    elsif alert_type.termly? && @school.holiday_approaching?
      return true
    # elsif alert_type.weekly? && @school.complete_previous_week_of_readings? && Date.today.wednesday?
    #   return true
    end
    false
  end

  def aggregate_school
    cache_key = "#{@school.name.parameterize}-aggregated_meter_collection"
    Rails.cache.fetch(cache_key, expires_in: 1.day) do
      meter_collection = MeterCollection.new(@school)
      AggregateDataService.new(meter_collection).validate_and_aggregate_meter_data
    end
  end
end

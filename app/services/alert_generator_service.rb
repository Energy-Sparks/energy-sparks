require 'dashboard'
require 'twilio-ruby'

class AlertGeneratorService
  def initialize(school, analysis_date = Date.new(2018, 2, 2))
    @school = school
    @analysis_date = analysis_date

    account_sid = ENV['TWILIO_ACCOUNT_SID']
    auth_token = ENV['TWILIO_AUTH_TOKEN']
    @from_phone_number = ENV['TWILIO_PHONE_NUMBER']

    @twilio_client = Twilio::REST::Client.new(account_sid, auth_token)
  end

  def perform
    return [] unless @school.alerts?
    @results = AlertType.all.map do |alert_type|
      alert = alert_type.class_name.constantize.new(aggregate_school)
      alert.analyse(@analysis_date)
      { report: alert.analysis_report, title: alert_type.title, description: alert_type.description }
    end
  end

  def generate_for_contacts(run_all = false)
    return if @school.contacts.empty?

    @school.contacts.each do |contact|
      alerts_for_contact = get_alerts(contact, run_all).compact!
      process_alerts_for_contact(contact, alerts_for_contact) if alerts_for_contact.present?
    end
  end

private

  def process_alerts_for_contact(contact, alerts)
    if contact.email_address?
      AlertMailer.with(email_address: contact.email_address, alerts: alerts, school: @school).alert_email.deliver_now
    end

    if contact.mobile_phone_number?
      alerts.each do |alert|
        # Temporary hard coding of messages
        if alert[:title] == 'Turn heating on/off' || alert[:title] == 'Holiday coming up'
          Rails.logger.info "Send SMS message"
          @twilio_client.messages.create(body: "EnergySparks alert: " + alert[:analysis_report].summary, to: contact.mobile_phone_number, from: @from_phone_number)
        end
      end
    end
  end

  # Get array of alerts for this contact
  def get_alerts(contact, run_all = false)
    contact.alerts.map do |alert|
      next unless run_all || run_this_alert?(alert)

      alert_type_class = alert.alert_type_class
      alert_object = alert_type_class.new(aggregate_school)

      begin
        alert_object.analyse(@analysis_date)
        Rails.logger.info "Alert generated for #{@school.name} on #{@analysis_date} : #{alert.title}"
        { analysis_report: alert_object.analysis_report, title: alert.title, description: alert.description }
      rescue
        Rails.logger.warn "Alert generation failed for #{@school.name} on #{@analysis_date} : #{alert_type_class}"
        nil
      end
    end
  end

  def run_this_alert?(alert)
    alert_type = alert.alert_type
    if alert_type.before_each_holiday? && @school.holiday_approaching?
      return true
    elsif alert_type.termly? && @school.holiday_approaching?
      return true
    elsif alert_type.weekly? && Time.zone.today.wednesday?
      if @school.has_last_full_week_of_readings?
        return true
      else
        Rails.logger.warn "#{@school} does not have a complete previous week of readings for #{Time.zone.today}"
      end
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

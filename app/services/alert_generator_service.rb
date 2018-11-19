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
      { report: alert.analysis_report, title: alert_type.title, description: alert_type.description, frequency: alert_type.frequency }
    end
  end

  def generate_for_contacts(run_all = false)
    return if @school.contacts.empty?

    @school.contacts.each do |contact|
      alerts_for_contact = get_alerts(contact, run_all).compact!
      process_alerts_for_contact(contact, alerts_for_contact)
    end
  end

private

  def process_alerts_for_contact(contact, alerts)
    return if alerts.nil? || alerts.empty?

    if contact.email_address?
      AlertMailer.with(email_address: contact.email_address, alerts: alerts, school: @school).alert_email.deliver_now
    end

    if contact.mobile_phone_number?
      alerts.each do |alert|
        if should_send_heating_holiday_message?(alert[:analysis_report])
          Rails.logger.info "Send SMS message to #{contact.name} #{contact.mobile_phone_number} of #{alert[:analysis_report].summary}"
          @twilio_client.messages.create(body: "EnergySparks alert: " + alert[:analysis_report].summary, to: contact.mobile_phone_number, from: @from_phone_number)
        else
          Rails.logger.debug "Do not send SMS message to #{contact.name} #{contact.mobile_phone_number} of #{alert[:analysis_report].summary} #{alert[:analysis_report].type}"
        end
      end
    else
      Rails.logger.debug "#{contact.name} does not have a phone number"
    end
  end

  def should_send_heating_holiday_message?(analysis_report)
    is_it_turn_heating_on_and_off?(analysis_report) || is_holiday_coming_up_and_message_to_be_sent?(analysis_report)
  end

  def is_it_turn_heating_on_and_off?(analysis_report)
    # Temporary hard coding of messages
    analysis_report.type == :turnheatingonoff
  end

  def is_holiday_coming_up_and_message_to_be_sent?(analysis_report)
    # Temporary hard coding of messages
    analysis_report.type == :upcomingholiday && analysis_report.summary != AlertImpendingHoliday::NO_ACTION_REQUIRED_SUMMARY
  end

  def is_holiday_coming_up_and_message_not_to_be_sent?(analysis_report)
    # Temporary hard coding of messages
    analysis_report.type == :upcomingholiday && analysis_report.summary == AlertImpendingHoliday::NO_ACTION_REQUIRED_SUMMARY
  end

  # Get array of alerts for this contact
  def get_alerts(contact, run_all = false)
    contact.alerts.map do |alert|
      next unless run_all || run_this_alert?(alert)

      alert_type_class = alert.alert_type_class
      alert_object = alert_type_class.new(aggregate_school)

      begin
        alert_object.analyse(@analysis_date)
        analysis_report = alert_object.analysis_report
        next if is_holiday_coming_up_and_message_not_to_be_sent?(analysis_report)

        Rails.logger.info "Alert generated for #{@school.name} on #{@analysis_date} : #{alert.title}"
        { analysis_report: analysis_report, title: alert.title, description: alert.description }
      rescue
        Rails.logger.warn "Alert generation failed for #{@school.name} on #{@analysis_date} : #{alert_type_class}"
        nil
      end
    end
  end

  def run_this_alert?(alert)
    alert_type = alert.alert_type
    if alert_type.before_each_holiday?
      # Run regardless and catch in is_holiday_coming_up_and_message_to_be_sent?(alert)
      return true
    elsif alert_type.termly? && @school.holiday_approaching?
      return true
    elsif alert_type.weekly? && Time.zone.today.wednesday?
      if @school.has_last_full_week_of_readings?
        return true
      else
        Rails.logger.warn "#{@school.name} does not have a complete previous week of readings for #{Time.zone.today}"
      end
    end
    false
  end

  def aggregate_school
    cache_key = "#{@school.name.parameterize}-aggregated_meter_collection"
    Rails.cache.fetch(cache_key, expires_in: 3.hours) do
      meter_collection = MeterCollection.new(@school)
      AggregateDataService.new(meter_collection).validate_and_aggregate_meter_data
    end
  end
end

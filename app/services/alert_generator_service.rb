require 'dashboard'

class AlertGeneratorService
  def initialize(school, aggregate_school, gas_analysis_date, electricity_analysis_date, send_sms_service = SendSms)
    @school = school
    @gas_analysis_date = gas_analysis_date
    @electricity_analysis_date = electricity_analysis_date
    @send_sms_service = send_sms_service
    @aggregate_school = aggregate_school
  end

  def perform
    return [] unless @school.alert_subscriptions?
    @results = []

    @results << run_alerts(AlertType.no_fuel)

    if @school.meters_with_enough_validated_readings_for_analysis(:electricity).any?
      @results << run_alerts(AlertType.electricity, @electricity_analysis_date)
    end
    if @school.meters_with_enough_validated_readings_for_analysis(:gas).any?
      @results << run_alerts(AlertType.gas, @gas_analysis_date)
    end
    @results.flatten
  end

  def generate_for_contacts(run_all = false)
    return if @school.contacts.empty?

    @school.contacts.each do |contact|
      alerts_for_contact = get_alerts(contact, run_all).compact!
      process_alerts_for_contact(contact, alerts_for_contact)
    end
  end

private

  def run_alerts(alert_types, analysis_date = Time.zone.today)
    alert_types.map do |alert_type|
      run_alert(alert_type, analysis_date)
    end
  end

  def run_alert(alert_type, analysis_date)
    alert = alert_type.class_name.constantize.new(@aggregate_school)
    begin
      alert.analyse(analysis_date)
      report = alert.analysis_report
      # Data problems usually throw this: undefined method `kwh_data_x48' for nil:NilClass
    rescue NoMethodError
      report = AlertReport.new(alert_type)
      report.summary = "There was a problem running this alert: #{alert_type.title}."
      report.rating = 0.0
      Rails.logger.error("There was a problem running #{alert_type.title} for #{analysis_date} and #{@school.name}")
    end
    { report: report, title: alert_type.title, description: alert_type.description, frequency: alert_type.frequency, fuel_type: alert_type.fuel_type }
  end

  def alert_types_for_school
    alert_types = AlertType.no_fuel_type

    if @school.meters_with_enough_validated_readings_for_analysis(:electricity).any?
      alert_types << AlertType.where(fuel_type: :electricity).to_a
    end

    if @school.meters_with_enough_validated_readings_for_analysis(:gas).any?
      alert_types << AlertType.where(fuel_type: :gas).to_a
    end
    alert_types.flatten
  end

  def process_alerts_for_contact(contact, alerts)
    return if alerts.nil? || alerts.empty?

    if contact.email_address?
      AlertMailer.with(email_address: contact.email_address, alerts: alerts, school: @school).alert_email.deliver_now
    end

    if contact.mobile_phone_number?
      alerts.each do |alert|
        if should_send_heating_holiday_message?(alert[:analysis_report])
          Rails.logger.info "Send SMS message to #{contact.name} #{contact.mobile_phone_number} of #{alert[:analysis_report].summary}"
          @send_sms_service.new("EnergySparks alert: " + alert[:analysis_report].summary, contact.mobile_phone_number).send
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
    contact.alert_subscriptions.map do |alert|
      next unless run_all || run_this_alert?(alert)

      alert_type_class = alert.alert_type_class
      alert_object = alert_type_class.new(@aggregate_school)

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
end

class SchoolCreator
  def initialize(school)
    @school = school
  end

  def onboard_school!(onboarding)
    if @school.valid?
      @school.update!(
        school_group: onboarding.school_group,
        calendar_area: onboarding.calendar_area,
        solar_pv_tuos_area: onboarding.solar_pv_tuos_area,
        weather_underground_area: onboarding.weather_underground_area
      )
      @school.transaction do
        record_event(onboarding, :school_admin_created) do
          onboarding.created_user.update!(school: @school, role: :school_admin)
        end
        record_events(onboarding, :default_school_times_added, :default_alerts_assigned) do
          process_new_school!
        end
        process_new_configuration!
        record_event(onboarding, :school_calendar_created) if @school.calendar
        record_event(onboarding, :school_details_created) do
          onboarding.update!(school: @school)
        end
      end
    end
    @school
  end

  def process_new_school!
    add_school_times
    add_all_alert_types
  end

  def activate_school!
    @school.update!(active: true)
    if @school.school_onboarding && !@school.school_onboarding.has_event?(:activation_email_sent)
      OnboardingMailer.with(school_onboarding: @school.school_onboarding).activation_email.deliver_now
      record_event(@school.school_onboarding, :activation_email_sent)
    end
  end

  def add_all_alert_types
    AlertType.all.each do |alert_type|
      @school.alert_subscriptions.create(alert_type: alert_type) unless @school.alert_subscriptions.where(alert_type: alert_type).exists?
    end
  end

  def add_school_times
    SchoolTime.days.each do |day, _value|
      @school.school_times.create(day: day)
    end
  end

  def process_new_configuration!
    generate_calendar
  end

private

  def generate_calendar
    if (area = @school.calendar_area)
      if (template = area.calendars.find_by(template: true))
        calendar = CalendarFactory.new(template, @school.name).create
        @school.update!(calendar: calendar)
      end
    end
  end

  def record_event(onboarding, *events)
    result = yield if block_given?
    events.each do |event|
      onboarding.events.create(event: event)
    end
    result
  end
  alias_method :record_events, :record_event
end

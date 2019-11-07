class SchoolCreator
  def initialize(school)
    @school = school
  end

  def onboard_school!(onboarding)
    if @school.valid?
      @school.transaction do
        copy_onboarding_details_to_school(onboarding)
        record_event(onboarding, :school_admin_created) do
          onboarding.created_user.update!(school: @school, role: :school_admin)
        end
        record_events(onboarding, :default_school_times_added) do
          process_new_school!
        end
        create_default_contact(onboarding)
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
    generate_configuration
  end

  def make_visible!
    @school.update!(visible: true)
    if should_send_activation_email?
      OnboardingMailer.with(school_onboarding: @school.school_onboarding).activation_email.deliver_now
      record_event(@school.school_onboarding, :activation_email_sent)
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

  def copy_onboarding_details_to_school(onboarding)
      @school.update!(
        school_group: onboarding.school_group,
        template_calendar: onboarding.template_calendar,
        solar_pv_tuos_area: onboarding.solar_pv_tuos_area,
        dark_sky_area: onboarding.dark_sky_area
      )
  end

  def create_default_contact(onboarding)
    record_events(onboarding, :alert_contact_created) do
      @school.contacts.create!(
        name: onboarding.created_user.name,
        email_address: onboarding.created_user.email,
        description: 'School Energy Sparks contact'
      )
    end
  end

  def should_send_activation_email?
    @school.school_onboarding && !@school.school_onboarding.has_event?(:activation_email_sent)
  end

  def generate_calendar
    if (template_calendar = @school.template_calendar)
      calendar = CalendarFactory.new(existing_calendar: template_calendar, title: @school.name, calendar_type: :school).create
      @school.update!(calendar: calendar)
    else
      @school.update!(calendar: nil)
    end
  end

  def generate_configuration
    return if @school.configuration
    Schools::Configuration.create!(school: @school)
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

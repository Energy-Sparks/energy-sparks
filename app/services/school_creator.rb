class SchoolCreator
  def initialize(school)
    @school = school
  end

  def onboard_school!(onboarding)
    if @school.valid?
      @school.transaction do
        copy_onboarding_details_to_school(onboarding)
        record_event(onboarding, :school_admin_created) do
          add_school(onboarding.created_user, @school)
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
    record_event(@school.school_onboarding, :onboarding_complete) if should_complete_onboarding?
    if should_send_activation_email?
      to = activation_email_list(@school)
      if to.any?
        target_prompt = include_target_prompt_in_email?
        OnboardingMailer.with(to: to, school: @school, target_prompt: target_prompt).activation_email.deliver_now

        record_event(@school.school_onboarding, :activation_email_sent) unless @school.school_onboarding.nil?
        record_target_event(@school, :first_target_sent) if target_prompt
      end
      enrol_in_default_programme
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

  def activation_email_list(school)
    users = []
    if school.school_onboarding && school.school_onboarding.created_user.present?
      users << school.school_onboarding.created_user
    end
    #also email admin, staff and group users
    users += (school.school_admin.to_a + school.cluster_users.to_a + school.users.staff.to_a)
    users.uniq.map(&:email)
  end

  def add_school(user, school)
    user.add_cluster_school(school)
    user.update!(school: school, role: :school_admin) unless user.school
  end

  def copy_onboarding_details_to_school(onboarding)
      @school.update!(
        school_group: onboarding.school_group,
        template_calendar: onboarding.template_calendar,
        solar_pv_tuos_area: onboarding.solar_pv_tuos_area,
        dark_sky_area: onboarding.dark_sky_area,
        scoreboard: onboarding.scoreboard,
        weather_station: onboarding.weather_station
      )
  end

  def create_default_contact(onboarding)
    record_events(onboarding, :alert_contact_created) do
      @school.contacts.create!(
        user: onboarding.created_user,
        name: onboarding.created_user.display_name,
        email_address: onboarding.created_user.email,
        description: 'School Energy Sparks contact'
      )
    end
  end

  def should_send_activation_email?
    @school.school_onboarding.nil? || @school.school_onboarding && !@school.school_onboarding.has_event?(:activation_email_sent)
  end

  def include_target_prompt_in_email?
    return EnergySparks::FeatureFlags.active?(:school_targets) && Targets::SchoolTargetService.new(@school).enough_data?
  end

  def enrol_in_default_programme
    Programmes::Enroller.new.enrol(@school)
  end

  def should_complete_onboarding?
    @school.school_onboarding && @school.school_onboarding.incomplete?
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

  def record_target_event(school, event)
    school.school_target_events.create(event: event)
  end
end

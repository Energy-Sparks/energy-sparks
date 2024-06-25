class SchoolCreator
  include Wisper::Publisher

  class Error < StandardError; end

  def initialize(school)
    @school = school
  end

  def onboard_school!(onboarding)
    @school.assign_attributes(
      onboarding.slice(:school_group, :template_calendar, :dark_sky_area, :scoreboard, :weather_station, :funder)
    )
    if @school.valid?
      @school.transaction do
        copy_onboarding_details_to_school(onboarding)
        onboarding_service.record_event(onboarding, :school_admin_created) do
          add_school(onboarding.created_user, @school)
        end
        onboarding_service.record_event(onboarding, :default_school_times_added) do
          process_new_school!
        end
        create_default_contact(onboarding)
        process_new_configuration!
        onboarding_service.record_event(onboarding, :school_calendar_created) if @school.calendar
        onboarding_service.record_event(onboarding, :school_details_created) do
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
    raise Error.new('School cannot be made visible as we dont have a record of consent') unless @school.consent_grants.any?
    @school.update!(visible: true)
    if onboarding_service.should_complete_onboarding?(@school)
      users = @school.users.reject(&:pupil?)
      onboarding_service.complete_onboarding(@school.school_onboarding, users)
    end
    broadcast(:school_made_visible, @school)
  end

  def make_data_enabled!
    raise Error.new('School must be visible before enabling data') unless @school.visible
    @school.update!(data_enabled: true)
    @school.update!(activation_date: Time.zone.today) unless @school.activation_date.present?
    onboarding_service.record_event(@school.school_onboarding, :onboarding_data_enabled)
    broadcast(:school_made_data_enabled, @school)
  end

  def add_school_times
    SchoolTime.days.each do |day, day_number|
      @school.school_times.create(day: day) if day_number <= 4
    end
  end

  def process_new_configuration!
    generate_calendar
  end

private

  def add_school(user, school)
    return if user.group_admin? || user.admin?

    user.add_cluster_school(school)
    user.update!(school: school, role: :school_admin) unless user.school
  end

  def copy_onboarding_details_to_school(onboarding)
    @school.update!(
      public: onboarding.school_will_be_public,
      chart_preference: onboarding.default_chart_preference
    )
    Solar::SolarAreaLookupService.new(@school, onboarding).assign
  end

  def create_default_contact(onboarding)
    return if onboarding.created_user.group_admin?
    onboarding_service.record_event(onboarding, :alert_contact_created) do
      @school.contacts.create!(
        user: onboarding.created_user,
        name: onboarding.created_user.display_name,
        email_address: onboarding.created_user.email,
        description: 'School Energy Sparks contact'
      )
    end
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

  def onboarding_service
    @onboarding_service ||= Onboarding::Service.new
  end
end

# == Schema Information
#
# Table name: school_onboardings
#
#  contact_email            :string           not null
#  country                  :integer          default("england"), not null
#  created_at               :datetime         not null
#  created_by_id            :bigint(8)
#  created_user_id          :bigint(8)
#  dark_sky_area_id         :bigint(8)
#  default_chart_preference :integer          default("default"), not null
#  id                       :bigint(8)        not null, primary key
#  notes                    :text
#  school_group_id          :bigint(8)
#  school_id                :bigint(8)
#  school_name              :string           not null
#  school_will_be_public    :boolean          default(TRUE)
#  scoreboard_id            :bigint(8)
#  solar_pv_tuos_area_id    :bigint(8)
#  template_calendar_id     :bigint(8)
#  updated_at               :datetime         not null
#  uuid                     :string           not null
#  weather_station_id       :bigint(8)
#
# Indexes
#
#  index_school_onboardings_on_created_by_id          (created_by_id)
#  index_school_onboardings_on_created_user_id        (created_user_id)
#  index_school_onboardings_on_school_group_id        (school_group_id)
#  index_school_onboardings_on_school_id              (school_id)
#  index_school_onboardings_on_scoreboard_id          (scoreboard_id)
#  index_school_onboardings_on_solar_pv_tuos_area_id  (solar_pv_tuos_area_id)
#  index_school_onboardings_on_template_calendar_id   (template_calendar_id)
#  index_school_onboardings_on_uuid                   (uuid) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (created_by_id => users.id) ON DELETE => nullify
#  fk_rails_...  (created_user_id => users.id) ON DELETE => nullify
#  fk_rails_...  (school_group_id => school_groups.id) ON DELETE => restrict
#  fk_rails_...  (school_id => schools.id) ON DELETE => cascade
#  fk_rails_...  (scoreboard_id => scoreboards.id) ON DELETE => nullify
#  fk_rails_...  (solar_pv_tuos_area_id => areas.id) ON DELETE => restrict
#  fk_rails_...  (template_calendar_id => calendars.id) ON DELETE => nullify
#

class SchoolOnboarding < ApplicationRecord
  validates :school_name, :contact_email, presence: true

  belongs_to :school, optional: true
  belongs_to :school_group, optional: true
  belongs_to :template_calendar, optional: true, class_name: 'Calendar'
  belongs_to :solar_pv_tuos_area, optional: true
  belongs_to :dark_sky_area, class_name: 'DarkSkyArea', optional: true
  belongs_to :weather_station, optional: true
  belongs_to :scoreboard, optional: true
  belongs_to :created_user, class_name: 'User', optional: true
  belongs_to :created_by, class_name: 'User', optional: true

  has_many :events, class_name: 'SchoolOnboardingEvent'

  scope :by_name, -> { order(school_name: :asc) }
  scope :complete, -> { joins(:events).where(school_onboarding_events: { event: SchoolOnboardingEvent.events[:onboarding_complete] }) }
  scope :incomplete, ->(parent = nil) { where.not(id: parent ? parent.school_onboardings.complete : complete) }
  scope :for_school_type, ->(school_type) { joins(:school).where(schools: { school_type: school_type }) }

  enum default_chart_preference: [:default, :carbon, :usage, :cost]
  enum country: School.countries

  def has_event?(event_name)
    events.where(event: event_name).any?
  end

  def has_event_older_than?(event_name, created_at)
    events.where(event: event_name, created_at: ..created_at).any?
  end

  def has_only_sent_email_or_reminder?
    (events.pluck(:event).map(&:to_sym) - [:email_sent, :reminder_sent]).empty?
  end

  def complete?
    has_event?(:onboarding_complete)
  end

  def completed_on
    complete? ? events.where(event: :onboarding_complete).last.created_at : nil
  end

  def incomplete?
    !complete?
  end

  def started?
    !has_only_sent_email_or_reminder?
  end

  def onboarding_user_created?
    has_event?(:onboarding_user_created)
  end

  def school_details_created?
    has_event?(:school_details_created)
  end

  def pupil_account_created?
    has_event?(:pupil_account_created)
  end

  def permission_given?
    has_event?(:permission_given)
  end

  def additional_users_created?
    school.present? && school.users.count {|u| !u.pupil?} > 1
  end

  def ready_for_review?
    #adding pupil password is trigger for last step
    pupil_account_created?
  end

  def email_locales
    country == 'wales' ? [:en, :cy] : [:en]
  end

  def to_param
    uuid
  end

  def page_anchor
    school_group.slug if school_group
  end

  def onboarding_completed_on
    events.onboarding_complete.minimum(:created_at)
  end

  def first_made_data_enabled
    events.onboarding_data_enabled.minimum(:created_at)
  end

  def days_until_data_enabled
    return nil unless complete?
    data_enabled_on = first_made_data_enabled
    return nil unless data_enabled_on.present?
    (data_enabled_on.to_date - onboarding_completed_on.to_date).to_i
  end
end

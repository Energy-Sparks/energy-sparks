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
#  data_sharing             :enum             default("public"), not null
#  default_chart_preference :integer          default("default"), not null
#  diocese_id               :bigint(8)
#  full_school              :boolean          default(TRUE)
#  funder_id                :bigint(8)
#  id                       :bigint(8)        not null, primary key
#  local_authority_area_id  :bigint(8)
#  notes                    :text
#  project_group_id         :bigint(8)
#  school_group_id          :bigint(8)
#  school_id                :bigint(8)
#  school_name              :string           not null
#  school_will_be_public    :boolean          default(TRUE)
#  scoreboard_id            :bigint(8)
#  template_calendar_id     :bigint(8)
#  updated_at               :datetime         not null
#  urn                      :integer
#  uuid                     :string           not null
#  weather_station_id       :bigint(8)
#
# Indexes
#
#  index_school_onboardings_on_created_by_id            (created_by_id)
#  index_school_onboardings_on_created_user_id          (created_user_id)
#  index_school_onboardings_on_diocese_id               (diocese_id)
#  index_school_onboardings_on_funder_id                (funder_id)
#  index_school_onboardings_on_local_authority_area_id  (local_authority_area_id)
#  index_school_onboardings_on_project_group_id         (project_group_id)
#  index_school_onboardings_on_school_group_id          (school_group_id)
#  index_school_onboardings_on_school_id                (school_id)
#  index_school_onboardings_on_scoreboard_id            (scoreboard_id)
#  index_school_onboardings_on_template_calendar_id     (template_calendar_id)
#  index_school_onboardings_on_uuid                     (uuid) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (created_by_id => users.id) ON DELETE => nullify
#  fk_rails_...  (created_user_id => users.id) ON DELETE => nullify
#  fk_rails_...  (diocese_id => school_groups.id)
#  fk_rails_...  (local_authority_area_id => school_groups.id)
#  fk_rails_...  (project_group_id => school_groups.id)
#  fk_rails_...  (school_group_id => school_groups.id) ON DELETE => restrict
#  fk_rails_...  (school_id => schools.id) ON DELETE => cascade
#  fk_rails_...  (scoreboard_id => scoreboards.id) ON DELETE => nullify
#  fk_rails_...  (template_calendar_id => calendars.id) ON DELETE => nullify
#

class SchoolOnboarding < ApplicationRecord
  include Enums::DataSharing
  include RestrictsSchoolGroupTypes

  validates :school_name, presence: true
  validates :contact_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  belongs_to :school, optional: true
  belongs_to :school_group, optional: true
  belongs_to :project_group, -> { where(group_type: :project) }, class_name: 'SchoolGroup', optional: true
  belongs_to :diocese, -> { where(group_type: :diocese) }, class_name: 'SchoolGroup', optional: true
  belongs_to :local_authority_area, -> { where(group_type: :local_authority_area) }, class_name: 'SchoolGroup', optional: true
  belongs_to :template_calendar, optional: true, class_name: 'Calendar'
  belongs_to :dark_sky_area, class_name: 'DarkSkyArea', optional: true
  belongs_to :weather_station, optional: true
  belongs_to :scoreboard, optional: true
  belongs_to :created_user, class_name: 'User', optional: true
  belongs_to :created_by, class_name: 'User', optional: true
  belongs_to :funder, optional: true

  has_many :events, class_name: 'SchoolOnboardingEvent'
  has_many :issues, as: :issueable, dependent: :destroy

  scope :by_name, -> { order(school_name: :asc) }
  scope :complete, lambda {
    joins(:events).where(school_onboarding_events: { event: SchoolOnboardingEvent.events[:onboarding_complete] })
  }
  scope :incomplete, ->(parent = nil) { where.not(id: parent ? parent.onboardings_for_group.complete : complete) }
  scope :for_school_type, ->(school_type) { joins(:school).where(schools: { school_type: }) }

  enum :default_chart_preference, { default: 0, carbon: 1, usage: 2, cost: 3 }
  enum :country, School.countries

  def populate_default_values(user)
    assign_attributes({
                        uuid: SecureRandom.uuid,
                        created_by: user,
                        template_calendar: school_group&.default_template_calendar,
                        dark_sky_area: school_group&.default_dark_sky_area,
                        weather_station: school_group&.default_weather_station,
                        scoreboard: school_group&.default_scoreboard,
                        default_chart_preference: school_group&.default_chart_preference,
                        country: school_group&.default_country,
                        diocese: find_group(group_type: :diocese, code_attr: :diocese_code),
                        local_authority_area: find_group(group_type: :local_authority_area, code_attr: :la_code)
                      })
  end

  def has_event?(event_name)
    events.where(event: event_name).any?
  end

  def last_event(event_name)
    events.by_event_name(event_name).last
  end

  def last_event_older_than?(event_name, time)
    last_event(event_name) && last_event(event_name).created_at < time
  end

  def has_only_sent_email_or_reminder?
    (events.pluck(:event).map(&:to_sym) - %i[email_sent reminder_sent]).empty?
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
    school.present? && school.users.count { |u| !u.pupil? } > 1
  end

  def ready_for_review?
    # adding pupil password is trigger for last step
    pupil_account_created?
  end

  def email_locales
    country == 'wales' ? %i[en cy] : [:en]
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

  def name
    school_name
  end

  def find_group(group_type:, code_attr:)
    establishment = Lists::Establishment.current_establishment_from_urn(urn)
    return nil unless establishment && establishment&.public_send(code_attr)
    SchoolGroup.find_by(group_type:, dfe_code: establishment.public_send(code_attr))
  end
end

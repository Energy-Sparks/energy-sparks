# == Schema Information
#
# Table name: school_groups
#
#  admin_meter_statuses_electricity_id      :bigint(8)
#  admin_meter_statuses_gas_id              :bigint(8)
#  admin_meter_statuses_solar_pv_id         :bigint(8)
#  created_at                               :datetime         not null
#  default_chart_preference                 :integer          default("default"), not null
#  default_country                          :integer          default("england"), not null
#  default_dark_sky_area_id                 :bigint(8)
#  default_data_source_electricity_id       :bigint(8)
#  default_data_source_gas_id               :bigint(8)
#  default_data_source_solar_pv_id          :bigint(8)
#  default_issues_admin_user_id             :bigint(8)
#  default_procurement_route_electricity_id :bigint(8)
#  default_procurement_route_gas_id         :bigint(8)
#  default_procurement_route_solar_pv_id    :bigint(8)
#  default_scoreboard_id                    :bigint(8)
#  default_template_calendar_id             :bigint(8)
#  default_weather_station_id               :bigint(8)
#  description                              :string
#  dfe_code                                 :string
#  group_type                               :integer          default("general")
#  id                                       :bigint(8)        not null, primary key
#  mailchimp_fields_changed_at              :datetime
#  name                                     :string           not null
#  public                                   :boolean          default(TRUE)
#  slug                                     :string           not null
#  updated_at                               :datetime         not null
#
# Indexes
#
#  index_school_groups_on_default_issues_admin_user_id  (default_issues_admin_user_id)
#  index_school_groups_on_default_scoreboard_id         (default_scoreboard_id)
#  index_school_groups_on_default_template_calendar_id  (default_template_calendar_id)
#
# Foreign Keys
#
#  fk_rails_...  (default_issues_admin_user_id => users.id) ON DELETE => nullify
#  fk_rails_...  (default_scoreboard_id => scoreboards.id)
#  fk_rails_...  (default_template_calendar_id => calendars.id) ON DELETE => nullify
#

class SchoolGroup < ApplicationRecord
  extend FriendlyId
  include EnergyTariffHolder
  include ParentMeterAttributeHolder
  include Scorable
  include MailchimpUpdateable
  include AlphabeticalScopes

  watch_mailchimp_fields :name

  friendly_id :name, use: %i[finders slugged history]

  # LEGACY RELATIONSHIP FOR REMOVAL
  # Use assigned_schools instead to select schools linked to this group.
  #
  # Leaving this in place until we've tidied up all scopes and joins across the application
  has_many :schools

  has_many :school_groupings
  has_many :assigned_schools, through: :school_groupings, source: :school

  has_many :meters, through: :assigned_schools
  has_many :school_onboardings
  has_many :project_onboardings, class_name: 'SchoolOnboarding', foreign_key: :project_group_id

  has_many :calendars, through: :assigned_schools
  has_many :users

  has_many :school_group_partners, -> { order(position: :asc) }
  has_many :partners, through: :school_group_partners
  accepts_nested_attributes_for :school_group_partners, reject_if: proc { |attributes| attributes['position'].blank? }

  has_one :dashboard_message, as: :messageable, dependent: :destroy
  has_many :issues, as: :issueable, dependent: :destroy
  has_many :school_issues, through: :assigned_schools, source: :issues
  has_many :observations, through: :assigned_schools

  belongs_to :default_template_calendar, class_name: 'Calendar', optional: true
  belongs_to :default_dark_sky_area, class_name: 'DarkSkyArea', optional: true
  belongs_to :default_weather_station, class_name: 'WeatherStation',
                                       optional: true
  belongs_to :default_scoreboard, class_name: 'Scoreboard', optional: true
  belongs_to :default_issues_admin_user, class_name: 'User', optional: true
  belongs_to :admin_meter_status_electricity, class_name: 'AdminMeterStatus',
                                              foreign_key: 'admin_meter_statuses_electricity_id', optional: true
  belongs_to :admin_meter_status_gas, class_name: 'AdminMeterStatus', foreign_key: 'admin_meter_statuses_gas_id',
                                      optional: true
  belongs_to :admin_meter_status_solar_pv, class_name: 'AdminMeterStatus',
                                           foreign_key: 'admin_meter_statuses_solar_pv_id', optional: true
  belongs_to :default_data_source_electricity, class_name: 'DataSource', optional: true
  belongs_to :default_data_source_gas, class_name: 'DataSource',
                                       optional: true
  belongs_to :default_data_source_solar_pv, class_name: 'DataSource',
                                            optional: true
  belongs_to :default_procurement_route_electricity, class_name: 'ProcurementRoute', optional: true
  belongs_to :default_procurement_route_gas, class_name: 'ProcurementRoute', optional: true
  belongs_to :default_procurement_route_solar_pv, class_name: 'ProcurementRoute', optional: true
  belongs_to :funder, optional: true

  has_many :meter_attributes, inverse_of: :school_group, class_name: 'SchoolGroupMeterAttribute'

  has_many :energy_tariffs, as: :tariff_holder, dependent: :destroy

  has_many :clusters, class_name: 'SchoolGroupCluster', dependent: :destroy

  has_many :organisation_school_groupings, -> { where(role: 'organisation') }, class_name: 'SchoolGrouping'
  has_many :diocese_school_groupings, -> { where(role: 'diocese') }, class_name: 'SchoolGrouping'
  has_many :area_school_groupings, -> { where(role: 'area') }, class_name: 'SchoolGrouping'
  has_many :project_school_groupings, -> { where(role: 'project') }, class_name: 'SchoolGrouping'

  has_many :organisation_schools, through: :organisation_school_groupings, source: :school
  has_many :diocese_schools, through: :diocese_school_groupings, source: :school
  has_many :area_schools, through: :area_school_groupings, source: :school
  has_many :project_schools, through: :project_school_groupings, source: :school

  scope :by_name, -> { order(name: :asc) }
  scope :is_public, -> { where(public: true) }

  scope :with_visible_schools, -> {
    where(
      "id IN (
        SELECT DISTINCT school_groupings.school_group_id
        FROM school_groupings
        INNER JOIN schools ON schools.id = school_groupings.school_id
        WHERE schools.visible = TRUE
      )"
    )
  }

  # "general", "local_authority" and "multi_academy_trust" are considered to be "organisation" types. So will
  # be involved in "organisation" type SchoolGroupings.
  #
  # "diocese" and "local_authority_area" are considered to be "area" types. We need two group types for local authorities
  # in order to distinguish between the Local Authority as an organisation that maintains schools ("local_authority") and
  # the Local Authority as an administrative area whose boundary might contain schools that are maintained by other
  # organisations.
  #
  # A "diocese" here refers to an area. If a diocese (as an organisation) maintains schools then this would be represented
  # in the DfE database and our system as a multi_academy_trust.
  enum :group_type, { general: 0, local_authority: 1, multi_academy_trust: 2, diocese: 3, project: 4, local_authority_area: 5 }

  ORGANISATION_GROUP_TYPE_KEYS = %w[general local_authority multi_academy_trust].freeze
  AREA_GROUP_TYPE_KEYS = %w[local_authority_area].freeze
  DIOCESE_GROUP_TYPE_KEYS = %w[diocese].freeze
  PROJECT_GROUP_TYPE_KEYS = %w[project].freeze
  RESTRICTED_GROUP_TYPES = (AREA_GROUP_TYPE_KEYS + DIOCESE_GROUP_TYPE_KEYS + PROJECT_GROUP_TYPE_KEYS).freeze

  scope :organisation_groups, -> { where(group_type: ORGANISATION_GROUP_TYPE_KEYS) }
  scope :area_groups, -> { where(group_type: AREA_GROUP_TYPE_KEYS) }
  scope :diocese_groups, -> { where(group_type: DIOCESE_GROUP_TYPE_KEYS) }
  scope :project_groups, -> { where(group_type: PROJECT_GROUP_TYPE_KEYS) }

  validates :name, presence: true
  validates :dfe_code, uniqueness: true, allow_blank: true

  enum :default_chart_preference, { default: 0, carbon: 1, usage: 2, cost: 3 }
  enum :default_country, School.countries

  def self.organisation_group_types
    group_types.slice(*ORGANISATION_GROUP_TYPE_KEYS)
  end

  def self.area_group_types
    group_types.slice(*AREA_GROUP_TYPE_KEYS)
  end

  def self.project_group_types
    group_types.slice(*PROJECT_GROUP_TYPE_KEYS)
  end

  def self.diocese_group_types
    group_types.slice(*DIOCESE_GROUP_TYPE_KEYS)
  end

  def organisation?
    ORGANISATION_GROUP_TYPE_KEYS.include?(group_type)
  end

  def diocese?
    DIOCESE_GROUP_TYPE_KEYS.include?(group_type)
  end

  def visible_schools_count
    assigned_schools.visible.count
  end

  def fuel_types(schools_to_check = assigned_schools)
    school_ids = schools_to_check.data_visible.pluck(:id)
    return [] if school_ids.empty?

    query = <<-SQL.squish
      SELECT DISTINCT(fuel_types.key) FROM (
        SELECT
          row_to_json(json_each(fuel_configuration))->>'key' as key,
          (row_to_json(json_each(fuel_configuration))->>'value') as value
        FROM configurations
        WHERE school_id IN (#{school_ids.join(',')})
      ) as fuel_types
      WHERE fuel_types.value = 'true';
    SQL
    sanitized_query = ActiveRecord::Base.sanitize_sql_array(query)
    SchoolGroup.connection.select_all(sanitized_query).rows.flatten.map do |fuel_type|
      fuel_type.gsub('has_', '').to_sym
    end
  end

  def most_recent_content_generation_run
    ContentGenerationRun
      .joins(:school)
      .where(schools: { school_group_id: id })
      .order(created_at: :desc)
      .limit(1)
      .first
  end

  def has_visible_schools?
    assigned_schools.visible.any?
  end

  def has_schools_awaiting_activation?
    assigned_schools.awaiting_activation.any?
  end

  def safe_to_destroy?
    !(assigned_schools.any? || users.any?)
  end

  def safe_destroy
    raise EnergySparks::SafeDestroyError, 'Group has associated schools' if assigned_schools.any?
    raise EnergySparks::SafeDestroyError, 'Group has associated users' if users.any?

    destroy
  end

  def should_generate_new_friendly_id?
    name_changed? || super
  end

  def update_school_partner_positions!(position_attributes)
    transaction do
      school_group_partners.destroy_all
      update!(school_group_partners_attributes: position_attributes)
    end
  end

  def displayable_partners
    partners
  end

  def page_anchor
    name.parameterize
  end

  def self.with_active_schools
    joins(school_groupings: :school).merge(School.active).distinct
  end

  def all_issues
    Issue.for_school_group(self)
  end

  def email_locales
    default_country == 'wales' ? %i[en cy] : [:en]
  end

  def parent_tariff_holder
    SiteSettings.current
  end

  def holds_tariffs_of_type?(meter_type)
    Meter::MAIN_METER_TYPES.include?(meter_type.to_sym)
  end

  # For those groups without a scoreboard OR a default calendar (around 3-4)
  # default to using the academic year defined for the national scoreboard
  def this_academic_year(today: Time.zone.today)
    return super(today:) unless scorable_calendar.nil?
    NationalScoreboard.new.this_academic_year(today:)
  end

  # For those groups without a scoreboard OR a default calendar (around 3-4)
  # default to using the academic year defined for the national scoreboard
  def previous_academic_year(today: Time.zone.today)
    return super(today:) unless scorable_calendar.nil?
    NationalScoreboard.new.previous_academic_year(today:)
  end

  # Groups may have their calendars and scoreboards set up in different ways
  # depending on whether they are regionally located and centrally managed
  #
  # By default use the calendar for the scoreboard, this will be either the
  # English or Scottish calendar by default. Otherwise use the default
  # template calendar
  def scorable_calendar
    return default_scoreboard.academic_year_calendar unless default_scoreboard.nil?
    default_template_calendar
  end

  def national_calendar
    scorable_calendar&.national_calendar
  end

  def grouped_schools_by_name(scope: nil)
    selected_schools = scope ? assigned_schools.merge(scope) : assigned_schools
    selected_schools.group_by do |school|
      first_char = school.name[0]
      /[A-Za-z]/.match?(first_char) ? first_char.upcase : '#'
    end.sort.to_h
  end

  def scorable_schools
    assigned_schools
  end

  def onboardings_for_group
    project? ? project_onboardings : school_onboardings
  end

  def admin_form_label
    organisation? ? 'School group' : "#{group_type.humanize} group"
  end
end

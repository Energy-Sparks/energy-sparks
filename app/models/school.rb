# == Schema Information
#
# Table name: schools
#
#  activation_date                         :date
#  active                                  :boolean          default(TRUE)
#  address                                 :text
#  archived_date                           :date
#  bill_requested                          :boolean          default(FALSE)
#  bill_requested_at                       :datetime
#  calendar_id                             :bigint(8)
#  chart_preference                        :integer          default("default"), not null
#  cooks_dinners_for_other_schools         :boolean          default(FALSE), not null
#  cooks_dinners_for_other_schools_count   :integer
#  cooks_dinners_onsite                    :boolean          default(FALSE), not null
#  country                                 :integer          default("england"), not null
#  created_at                              :datetime         not null
#  dark_sky_area_id                        :bigint(8)
#  data_enabled                            :boolean          default(FALSE)
#  data_sharing                            :enum             default("public"), not null
#  enable_targets_feature                  :boolean          default(TRUE)
#  establishment_id                        :bigint(8)
#  floor_area                              :decimal(, )
#  full_school                             :boolean          default(TRUE)
#  funder_id                               :bigint(8)
#  funding_status                          :integer          default("state_school"), not null
#  has_swimming_pool                       :boolean          default(FALSE), not null
#  heating_air_source_heat_pump            :boolean          default(FALSE), not null
#  heating_air_source_heat_pump_notes      :text
#  heating_air_source_heat_pump_percent    :integer          default(0)
#  heating_biomass                         :boolean          default(FALSE), not null
#  heating_biomass_notes                   :text
#  heating_biomass_percent                 :integer          default(0)
#  heating_chp                             :boolean          default(FALSE), not null
#  heating_chp_notes                       :text
#  heating_chp_percent                     :integer          default(0)
#  heating_district_heating                :boolean          default(FALSE), not null
#  heating_district_heating_notes          :text
#  heating_district_heating_percent        :integer          default(0)
#  heating_electric                        :boolean          default(FALSE), not null
#  heating_electric_notes                  :text
#  heating_electric_percent                :integer          default(0)
#  heating_gas                             :boolean          default(FALSE), not null
#  heating_gas_notes                       :text
#  heating_gas_percent                     :integer          default(0)
#  heating_ground_source_heat_pump         :boolean          default(FALSE), not null
#  heating_ground_source_heat_pump_notes   :text
#  heating_ground_source_heat_pump_percent :integer          default(0)
#  heating_lpg                             :boolean          default(FALSE), not null
#  heating_lpg_notes                       :text
#  heating_lpg_percent                     :integer          default(0)
#  heating_oil                             :boolean          default(FALSE), not null
#  heating_oil_notes                       :text
#  heating_oil_percent                     :integer          default(0)
#  heating_underfloor                      :boolean          default(FALSE), not null
#  heating_underfloor_notes                :text
#  heating_underfloor_percent              :integer          default(0)
#  heating_water_source_heat_pump          :boolean          default(FALSE), not null
#  heating_water_source_heat_pump_notes    :text
#  heating_water_source_heat_pump_percent  :integer          default(0)
#  id                                      :bigint(8)        not null, primary key
#  indicated_has_solar_panels              :boolean          default(FALSE), not null
#  indicated_has_storage_heaters           :boolean          default(FALSE)
#  latitude                                :decimal(10, 6)
#  level                                   :integer          default(0)
#  local_authority_area_id                 :bigint(8)
#  local_distribution_zone_id              :bigint(8)
#  longitude                               :decimal(10, 6)
#  mailchimp_fields_changed_at             :datetime
#  met_office_area_id                      :bigint(8)
#  name                                    :string
#  number_of_pupils                        :integer
#  percentage_free_school_meals            :integer
#  postcode                                :string
#  process_data                            :boolean          default(FALSE)
#  public                                  :boolean          default(TRUE)
#  region                                  :integer
#  removal_date                            :date
#  school_group_cluster_id                 :bigint(8)
#  school_group_id                         :bigint(8)
#  school_type                             :integer          not null
#  scoreboard_id                           :bigint(8)
#  serves_dinners                          :boolean          default(FALSE), not null
#  slug                                    :string
#  solar_pv_tuos_area_id                   :bigint(8)
#  temperature_area_id                     :bigint(8)
#  template_calendar_id                    :integer
#  updated_at                              :datetime         not null
#  urn                                     :integer          not null
#  validation_cache_key                    :string           default("initial")
#  visible                                 :boolean          default(FALSE)
#  weather_station_id                      :bigint(8)
#  website                                 :string
#
# Indexes
#
#  index_schools_on_calendar_id                 (calendar_id)
#  index_schools_on_establishment_id            (establishment_id)
#  index_schools_on_latitude_and_longitude      (latitude,longitude)
#  index_schools_on_local_authority_area_id     (local_authority_area_id)
#  index_schools_on_local_distribution_zone_id  (local_distribution_zone_id)
#  index_schools_on_school_group_cluster_id     (school_group_cluster_id)
#  index_schools_on_school_group_id             (school_group_id)
#  index_schools_on_scoreboard_id               (scoreboard_id)
#  index_schools_on_urn                         (urn) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (calendar_id => calendars.id) ON DELETE => restrict
#  fk_rails_...  (school_group_cluster_id => school_group_clusters.id) ON DELETE => nullify
#  fk_rails_...  (school_group_id => school_groups.id) ON DELETE => restrict
#  fk_rails_...  (scoreboard_id => scoreboards.id) ON DELETE => nullify
#

require 'securerandom'

class School < ApplicationRecord
  extend FriendlyId
  include EnergyTariffHolder
  include ParentMeterAttributeHolder
  include MailchimpUpdateable
  include Enums::DataSharing
  include Enums::SchoolType
  include AlphabeticalScopes

  watch_mailchimp_fields :active, :country, :funder_id, :local_authority_area_id, :name, :percentage_free_school_meals,
                         :region, :school_group_id, :school_type, :scoreboard_id

  class ProcessDataError < StandardError; end

  HEATING_TYPES = %i[gas electric oil lpg biomass underfloor district_heating ground_source_heat_pump
                     air_source_heat_pump water_source_heat_pump chp].freeze

  GOR_CODE_TO_REGION = {
    'A' => :north_east,
    'B' => :north_west,
    'D' => :yorkshire_and_the_humber,
    'E' => :east_midlands,
    'F' => :west_midlands,
    'G' => :east_of_england,
    'H' => :london,
    'J' => :south_east,
    'K' => :south_west
  }.freeze

  friendly_id :slug_candidates, use: %i[finders slugged history]

  delegate :holiday_approaching?, :next_holiday, to: :calendar

  has_and_belongs_to_many :key_stages, join_table: :school_key_stages

  has_many :users
  has_many :meters,               inverse_of: :school
  has_many :cads,                 inverse_of: :school
  has_many :school_times,         inverse_of: :school
  has_many :activities,           inverse_of: :school
  has_many :activity_types, through: :activities

  has_many :contacts,             inverse_of: :school
  has_many :observations,         inverse_of: :school
  has_many :intervention_types, through: :observations

  has_many :transport_surveys,    inverse_of: :school
  has_many :consent_documents,    inverse_of: :school
  has_many :meter_attributes,     inverse_of: :school, class_name: 'SchoolMeterAttribute'
  has_many :consent_grants,       inverse_of: :school
  has_many :meter_reviews,        inverse_of: :school
  has_many :school_targets,       inverse_of: :school
  has_many :school_target_events, inverse_of: :school
  has_many :audits,               inverse_of: :school

  # relationships to be removed when :todos removed
  has_many :audit_activity_types, -> { distinct }, through: :audits, source: :activity_types
  has_many :audit_intervention_types, -> { distinct }, through: :audits, source: :intervention_types

  has_many :audit_todos, through: :audits, source: :todos
  has_many :audit_activity_type_tasks, through: :audit_todos, source: :task, source_type: 'ActivityType'
  has_many :audit_intervention_type_tasks, through: :audit_todos, source: :task, source_type: 'InterventionType'

  has_many :programmes,               inverse_of: :school
  has_many :programme_types, through: :programmes

  # relationships to be removed when :todos removed
  has_many :programme_activity_types, through: :programmes, source: :activity_types

  has_many :alerts,                                   inverse_of: :school
  has_many :content_generation_runs,                  inverse_of: :school
  has_many :alert_generation_runs,                    inverse_of: :school
  has_many :subscription_generation_runs,             inverse_of: :school
  has_many :benchmark_result_school_generation_runs,  inverse_of: :school

  has_many :low_carbon_hub_installations, inverse_of: :school
  has_many :solar_edge_installations, inverse_of: :school
  has_many :rtone_variant_installations, inverse_of: :school
  has_many :solis_cloud_installation_schools
  has_many :solis_cloud_installations, through: :solis_cloud_installation_schools

  has_many :equivalences

  has_many :locations

  has_one :dashboard_message, as: :messageable, dependent: :destroy
  has_many :issues, as: :issueable, dependent: :destroy

  has_many :estimated_annual_consumptions

  has_many :amr_data_feed_readings,       through: :meters
  has_many :amr_validated_readings,       through: :meters
  has_many :alert_subscription_events,    through: :contacts

  has_many :school_alert_type_exclusions, dependent: :destroy
  has_many :school_batch_runs

  has_many :advice_page_school_benchmarks

  has_many :manual_readings, class_name: 'Schools::ManualReading', dependent: :destroy
  accepts_nested_attributes_for :manual_readings,
                                reject_if: proc { |attributes|
                                  attributes[:gas].blank? && attributes[:electricity].blank?
                                },
                                allow_destroy: true

  belongs_to :calendar, optional: true
  belongs_to :template_calendar, optional: true, class_name: 'Calendar'
  belongs_to :school_group_cluster, optional: true

  belongs_to :solar_pv_tuos_area, optional: true
  belongs_to :dark_sky_area, optional: true
  belongs_to :weather_station, optional: true

  belongs_to :school_group, optional: true
  delegate :default_issues_admin_user, to: :school_group

  belongs_to :scoreboard, optional: true
  belongs_to :local_authority_area, optional: true

  belongs_to :establishment, optional: true, class_name: 'Lists::Establishment'

  belongs_to :funder, optional: true
  belongs_to :local_distribution_zone, optional: true

  has_one :school_onboarding
  has_one :configuration, class_name: 'Schools::Configuration'

  has_and_belongs_to_many :cluster_users, class_name: 'User', join_table: :cluster_schools_users

  has_many :school_partners, -> { order(position: :asc) }
  has_many :partners, through: :school_partners
  accepts_nested_attributes_for :school_partners, reject_if: proc { |attributes| attributes['position'].blank? }

  has_many :school_groupings, dependent: :destroy
  has_many :assigned_school_groups, through: :school_groupings, source: :school_group

  # filtered relationships
  has_one :organisation_school_grouping, -> { where(role: 'organisation') }, class_name: 'SchoolGrouping'
  accepts_nested_attributes_for :organisation_school_grouping, update_only: true

  has_many :area_school_groupings, -> { where(role: 'area') }, class_name: 'SchoolGrouping'
  has_many :project_school_groupings, -> { where(role: 'project') }, class_name: 'SchoolGrouping'
  accepts_nested_attributes_for :project_school_groupings, allow_destroy: true

  # school groups via the filtered SchoolGrouping relationships
  has_one :organisation_group, through: :organisation_school_grouping, source: :school_group
  has_many :area_groups, through: :area_school_groupings, source: :school_group
  has_many :project_groups, through: :project_school_groupings, source: :school_group

  enum :chart_preference, { default: 0, carbon: 1, usage: 2, cost: 3 }
  enum :country, { england: 0, scotland: 1, wales: 2 }
  enum :funding_status, { state_school: 0, private_school: 1 }
  enum :region, { north_east: 0, north_west: 1, yorkshire_and_the_humber: 2, east_midlands: 3,
                  west_midlands: 4, east_of_england: 5, london: 6, south_east: 7, south_west: 8 }

  # active flag is a soft-delete, those with a removal date are deleted, others
  # are archived, with chance of returning if we receive funding
  scope :active,              -> { where(active: true) }
  scope :inactive,            -> { where(active: false) }
  scope :archived,            -> { inactive.where(removal_date: nil) }
  scope :deleted,             -> { inactive.where.not(removal_date: nil) }
  scope :visible,             -> { active.where(visible: true) }
  scope :not_visible,         -> { active.where(visible: false) }
  scope :process_data,        -> { active.where(process_data: true) }
  scope :data_enabled,        -> { active.where(data_enabled: true) }
  scope :without_group,       -> { active.where(school_group_id: nil) }
  scope :without_scoreboard,  -> { active.where(scoreboard_id: nil) }
  scope :awaiting_activation, -> { active.where('visible = ? or data_enabled = ?', false, false) }
  scope :data_visible,        -> { data_enabled.visible }

  scope :with_config, -> { joins(:configuration) }

  scope :by_name,     -> { order(name: :asc) }

  scope :not_in_cluster, -> { where(school_group_cluster_id: nil) }

  scope :with_community_use, -> { where(id: SchoolTime.community_use.select(:school_id)) }

  scope :with_establishment, -> { where.not(establishment_id: nil) }

  # includes creating a target, recording activities and actions, having an audit, starting a programme, recording temperatures
  scope :with_recent_engagement,
        ->(range) { where(id: Observation.engagement.recorded_since(range).select(:school_id)) }

  # have recently run a transport survey
  scope :with_transport_survey, ->(range) { where(id: TransportSurvey.recently_added(range).select(:school_id)) }

  # have recently started a programme that isn't the default programme
  scope :joined_programme, ->(range) { where(id: Programme.recently_started_non_default(range).select(:school_id)) }

  # TODO: cluster users, not just those directly linked
  scope :with_recently_logged_in_users, ->(date) { where(id: User.recently_logged_in(date).select(:school_id)) }

  scope :unfunded, -> { where(schools: { funder_id: nil }) }


  scope :missing_alert_contacts, -> { where('schools.id NOT IN (SELECT distinct(school_id) from contacts)') }

  def self.with_energy_tariffs
    joins("INNER JOIN energy_tariffs ON energy_tariffs.tariff_holder_id = schools.id AND tariff_holder_type = 'School'")
      .group('schools.id').order('schools.name')
  end

  # combination of other scopes to define an engaged school
  def self.engaged(date_range)
    active.and(with_recent_engagement(date_range)
               .or(with_recently_logged_in_users(date_range.begin))
               .or(with_transport_survey(date_range))
               .or(joined_programme(date_range)))
  end

  validates :name, :address, :postcode, :website, :school_type, presence: true
  validates :urn, presence: true, uniqueness: true,
                  numericality: { less_than_or_equal_to: (2**31) - 1,
                                  message: 'the URN or SEED you have supplied appears to be invalid' }
  validates :urn, numericality: { greater_than_or_equal_to: 10_000,
                                  message: 'the URN or SEED you have supplied appears to be invalid' }, on: :create
  validates :floor_area, :number_of_pupils, :cooks_dinners_for_other_schools_count,
            numericality: { greater_than: 0, allow_blank: true }
  validates :cooks_dinners_for_other_schools_count, presence: true, if: :cooks_dinners_for_other_schools?
  validates :country, inclusion: { in: countries }
  validates :funding_status, inclusion: { in: funding_statuses }

  validates :percentage_free_school_meals,
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100, allow_blank: true }
  # simplified pattern from: https://stackoverflow.com/questions/164979/regex-for-matching-uk-postcodes
  # adjusted to use \A and \z
  validates :postcode, format: { with: /\A[A-Z]{1,2}\d[A-Z\d]? ?\d[A-Z]{2}\z/i }
  validate :valid_uk_postcode, if: ->(school) { school.postcode.present? && school.postcode_changed? }

  validates_associated :school_times, on: :school_time_update

  validates(*HEATING_TYPES.map { |type| :"heating_#{type}_percent" },
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100, allow_blank: true })

  validates :weather_station, presence: true

  accepts_nested_attributes_for :school_times, reject_if: proc { |attributes| attributes['day'].blank? },
                                               allow_destroy: true

  auto_strip_attributes :name, :website, :postcode, squish: true

  before_validation :geocode, if: ->(school) { school.postcode.present? && school.postcode_changed? }

  before_save :update_local_distribution_zone, if: -> { saved_change_to_postcode }

  # Sync legacy school_group_id with new "organisation" grouping
  after_create :sync_organisation_grouping_from_legacy
  after_update :sync_organisation_grouping_from_legacy, if: :saved_change_to_school_group_id?

  geocoded_by :postcode do |school, results|
    if (geo = results.first)
      school.latitude = geo.data['latitude']
      school.longitude = geo.data['longitude']
      school.country = geo.data['country']&.downcase
    end
  end

  def deleted?
    not_active? and removal_date.present?
  end

  def archived?
    not_active? && removal_date.nil?
  end

  def not_active?
    !active
  end

  def minimum_reading_date
    return unless amr_validated_readings.present?

    # Ideally, we'd also use the minimum amr_data_feed_readings reading_date here, however, those reading dates are
    # currently stored as strings (and in an inconsistent date format as defined in the associated meter's amr data feed
    # config) so we instead use the minimum validated reading date minus 1 year.
    amr_validated_readings.minimum(:reading_date) - 1.year
  end

  def full_location_to_s
    return '' unless postcode.present?

    "#{postcode} (#{longitude}, #{latitude})"
  end

  def find_user_or_cluster_user_by_id(id)
    users.find_by_id(id) || cluster_users.find_by_id(id)
  end

  def latest_alert_run
    alert_generation_runs.order(created_at: :desc).first
  end

  def latest_alerts_without_exclusions
    if latest_alert_run
      latest_alert_run.alerts.without_exclusions
    else
      Alert.none
    end
  end

  def should_generate_new_friendly_id?
    slug.blank? || name_changed? || postcode_changed?
  end

  # Prevent the generated urls from becoming too long
  def normalize_friendly_id(string)
    super[0..59]
  end

  # Try building a slug based on the following fields in increasing order of specificity.
  def slug_candidates
    [
      :name,
      %i[postcode name],
      %i[urn name]
    ]
  end

  def current_academic_year
    academic_year_for(Time.zone.today)
  end

  def academic_year_for(date)
    calendar&.academic_year_for(date)
  end

  def activity_types_in_academic_year(date = Time.zone.now)
    activity_types.merge(activities.in_academic_year_for(self, date).by_date(:desc)).uniq # first occurance is kept when using uniq
  end

  def intervention_types_in_academic_year(date = Time.zone.now)
    intervention_types.merge(observations.in_academic_year_for(self, date).by_date(:desc)).uniq # first occurance is kept when using uniq
  end

  # to be removed when removing the todos feature
  def suggested_programme_types
    ProgrammeType.active.with_school_activity_type_count(self)
                 .merge(activities.in_academic_year(current_academic_year))
                 .not_in(programme_types)
  end

  def suggested_programme_types_from_activities
    ProgrammeType.active.not_in(programme_types)
                 .with_school_activity_type_task_count(self)
                 .merge(activities.in_academic_year(current_academic_year))
  end

  def suggested_programme_types_from_actions
    ProgrammeType.active.not_in(programme_types)
                 .with_school_intervention_type_task_count(self)
                 .merge(observations.in_academic_year(current_academic_year))
  end

  # returns array(ProgrammeType, count)
  def suggested_programme_type
    programme_types = suggested_programme_types_from_activities + suggested_programme_types_from_actions

    programme_types.each_with_object(Hash.new(0)) { |r, hash| hash[r] += r.recording_count }.max_by { |_, value| value }
  end

  delegate :national_calendar, to: :calendar

  def area_name
    school_group.name if school_group
  end

  def active_meters
    meters.where(active: true)
  end

  def meters_with_readings(supply = Meter.meter_types.keys)
    active_meters.joins(:amr_data_feed_readings).where(meter_type: supply).where.not(amr_data_feed_readings: { meter_id: nil }).distinct
  end

  def meters_with_validated_readings(supply = Meter.meter_types.keys)
    active_meters.joins(:amr_validated_readings).where(meter_type: supply).where.not(amr_validated_readings: { meter_id: nil }).distinct
  end

  def fuel_types
    if configuration.dual_fuel
      :electric_and_gas
    elsif configuration.has_electricity
      :electric_only
    elsif configuration.has_gas
      :gas_only
    else
      :none
    end
  end

  def has_gas?
    configuration.has_gas
  end

  def has_electricity?
    configuration.has_electricity
  end

  def analysis?
    configuration && configuration.analysis_charts.present?
  end

  delegate :fuel_types_for_analysis, to: :configuration

  def has_solar_pv?
    configuration.has_solar_pv
  end

  def has_storage_heaters?
    configuration.has_storage_heaters
  end

  def has_live_data?
    cads.active.any?
  end

  delegate :school_admin, to: :users

  delegate :staff, to: :users

  def all_school_admins
    school_admin + cluster_users
  end

  def all_adult_school_users
    (all_school_admins + staff).uniq
  end

  def activation_users
    users = []
    users << school_onboarding.created_user if school_onboarding && school_onboarding.created_user.present?
    # also email admin, staff and group users
    users += all_adult_school_users.to_a
    users.uniq
  end

  def latest_content
    content_generation_runs.order(created_at: :desc).first
  end

  def latest_adult_dashboard_alert_count
    @latest_adult_dashboard_alert_count ||= latest_dashboard_alerts.management_dashboard.count
  end

  def latest_dashboard_alerts
    if latest_content
      latest_content.dashboard_alerts
    else
      DashboardAlert.none
    end
  end

  def authenticate_pupil(pupil_password)
    users.pupil.to_a.find { |user| user.pupil_password.casecmp?(pupil_password) }
  end

  def filterable_meters(fuel_type)
    case fuel_type
    when :gas
      active_meters.gas.order(:mpan_mprn)
    when :electricity
      if has_storage_heaters?
        Meter.none
      else
        active_meters.electricity.order(:mpan_mprn)
      end
    else
      Meter.none
    end
  end

  def latest_management_priority_count
    @latest_management_priority_count ||= latest_management_priorities.count
  end

  def latest_management_priorities(exclude_capital: false)
    if latest_content
      priorities = latest_content.management_priorities
      priorities = priorities.without_investment if exclude_capital
      priorities
    else
      ManagementPriority.none
    end
  end

  def latest_management_dashboard_tables
    if latest_content
      latest_content.management_dashboard_tables
    else
      ManagementDashboardTable.none
    end
  end

  def latest_find_out_mores
    if latest_content
      latest_content.find_out_mores
    else
      FindOutMore.none
    end
  end

  def has_target?
    school_targets.any?
  end

  def has_current_target?
    current_target.present?
  end

  def current_target
    school_targets.by_start_date.detect(&:current?)
  end

  def most_recent_target
    school_targets.by_start_date.first
  end

  def expired_target
    school_targets.by_start_date.expired.first
  end

  def previous_expired_target(current_expired)
    idx = school_targets.by_start_date.expired.index { |t| t == current_expired } || return
    school_targets.by_start_date.expired[idx + 1]
  end

  def has_expired_target_for_fuel_type?(fuel_type)
    has_expired_target? && expired_target.try(fuel_type).present? && expired_target.saved_progress_report_for(fuel_type).present?
  end

  def has_expired_target?
    expired_target.present?
  end

  def has_school_target_event?(event_name)
    school_target_events.where(event: event_name).any?
  end

  def has_school_onboarding_event?(event_name)
    school_onboarding && school_onboarding.has_event?(event_name)
  end

  def suggest_annual_estimate?
    estimated_annual_consumptions.any? || configuration.suggest_annual_estimate?
  end

  def school_target_attributes
    # use the current target if we have one, otherwise the most current target
    # based on start date. So if target as expired, then progress pages still work
    if has_current_target?
      current_target.meter_attributes_by_meter_type
    elsif most_recent_target.present?
      most_recent_target.meter_attributes_by_meter_type
    else
      {}
    end
  end

  def latest_annual_estimate
    estimated_annual_consumptions.order(created_at: :desc).first
  end

  def estimated_annual_consumption_meter_attributes
    latest_annual_estimate.nil? ? {} : latest_annual_estimate.meter_attributes_by_meter_type
  end

  def school_group_pseudo_meter_attributes
    school_group ? school_group.pseudo_meter_attributes : {}
  end

  def global_pseudo_meter_attributes
    GlobalMeterAttribute.pseudo
  end

  def all_pseudo_meter_attributes
    all_attributes = [school_group_pseudo_meter_attributes,
                      pseudo_meter_attributes,
                      school_target_attributes]
                     .each_with_object(global_pseudo_meter_attributes) do |pseudo_attributes, collection|
      pseudo_attributes.each do |meter_type, attributes|
        collection[meter_type] ||= []
        collection[meter_type] = collection[meter_type] + attributes
      end
    end

    all_attributes[:aggregated_electricity] ||= []
    all_attributes[:aggregated_electricity] += all_energy_tariff_attributes(:electricity)

    all_attributes[:aggregated_gas] ||= []
    all_attributes[:aggregated_gas] += all_energy_tariff_attributes(:gas)

    all_attributes[:solar_pv_consumed_sub_meter] ||= []
    all_attributes[:solar_pv_consumed_sub_meter] += all_energy_tariff_attributes(:solar_pv)

    all_attributes[:solar_pv_exported_sub_meter] ||= []
    all_attributes[:solar_pv_exported_sub_meter] += all_energy_tariff_attributes(:exported_solar_pv)

    all_attributes
  end

  def pseudo_meter_attributes_to_analytics
    all_pseudo_meter_attributes.each_with_object({}) do |(meter_type, attributes), collection|
      collection[meter_type.to_sym] = MeterAttribute.to_analytics(attributes)
    end
  end

  def meter_attributes_to_analytics
    meters.order(:mpan_mprn).each_with_object({}) do |meter, collection|
      collection[meter.mpan_mprn] = meter.meter_attributes_to_analytics
    end
  end

  def invalidate_cache_key
    if Flipper.enabled?(:meter_collection_cache_delete_on_invalidate)
      AggregateSchoolService.new(self).invalidate_cache
    else
      update_attribute(:validation_cache_key, SecureRandom.uuid)
    end
  end

  def process_data!
    raise ProcessDataError, "#{name} cannot process data as it has no meter readings" if meters_with_readings.empty?
    raise ProcessDataError, "#{name} cannot process data as it has no floor area" if floor_area.blank?
    raise ProcessDataError, "#{name} cannot process data as it has no pupil numbers" if number_of_pupils.blank?

    update!(process_data: true)
  end

  def update_school_partner_positions!(position_attributes)
    transaction do
      school_partners.destroy_all
      update!(school_partners_attributes: position_attributes)
    end
  end

  def displayable_partners
    all_partners = partners
    all_partners += school_group.partners if school_group.present?
    all_partners
  end

  def consent_up_to_date?
    consent_grants.any? && consent_grants.by_date.first.consent_statement.current
  end

  def school_times_to_analytics
    school_times.school_day.map(&:to_analytics)
  end

  def community_use_times_to_analytics
    school_times.community_use.map(&:to_analytics)
  end

  def self.status_counts
    { active: visible.count, data_visible: data_visible.count, invisible: not_visible.count,
      removed: inactive.count }
  end

  def email_locales
    country == 'wales' ? %i[en cy] : [:en]
  end

  def subscription_frequency
    if holiday_approaching?
      %i[weekly termly before_each_holiday]
    else
      [:weekly]
    end
  end

  def recent_usage
    @recent_usage ||= Schools::ManagementTableService.new(self)&.management_data&.by_fuel_type_table || OpenStruct.new
  end

  def all_data_sources(meter_type)
    meters.active.where(meter_type:).data_source_known.joins(:data_source).order('data_sources.name ASC').distinct.pluck('data_sources.name')
  end

  def all_procurement_routes(meter_type)
    meters.active.where(meter_type:).procurement_route_known.joins(:procurement_route).order('procurement_routes.organisation_name ASC').distinct.pluck('procurement_routes.organisation_name')
  end

  def school_group_cluster_name
    school_group_cluster.try(:name) || I18n.t('common.labels.not_set')
  end

  def parent_tariff_holder
    school_group.presence || SiteSettings.current
  end

  def energy_tariff_meter_attributes(meter_type = EnergyTariff.meter_types.keys, applies_to = :both)
    raise InvalidAppliesToError unless EnergyTariff.applies_tos.key?(applies_to.to_s)

    applies_to_keys = [:both, applies_to].uniq

    energy_tariffs.where(meter_type:).where.missing(:meters).where(
      applies_to: applies_to_keys
    ).usable.map(&:meter_attribute)
  end

  def holds_tariffs_of_type?(meter_type)
    Meter::MAIN_METER_TYPES.include?(meter_type.to_sym) && meters.where(meter_type:).any?
  end

  def multiple_meters?(fuel_type)
    meters.active.where(meter_type: fuel_type).count > 1
  end

  def self.school_list_for_login_form
    School.left_joins(:school_group).select(:id, :name,
                                            'school_groups.name as school_group_name').where(visible: true).order(:name)
  end

  def data_visible?
    data_enabled && visible
  end

  def active_adult_users
    users.active.where.not(role: :pupil)
  end

  def active_alert_contacts
    users.active.alertable.joins(:contacts).where({ contacts: { school: self } })
  end

  # gov.uk have figures for recommended gross area for different sizes of schools.
  #
  # See:
  # https://assets.publishing.service.gov.uk/media/5f23ec238fa8f57acac33720/BB103_Area_Guidelines_for_Mainstream_Schools.pdf
  #
  # Is the floor area greater than a sensible minimum and less than twice the
  # gross recommended size. Base area and pupil sizes are taken from primary/secondary in the
  # government figures.
  def floor_area_ok?
    return true unless floor_area && number_of_pupils

    # all following are in m2
    case school_type.to_sym
    when :middle, :mixed_primary_and_secondary, :secondary
      minimum = 500
      base_area = 1700
      per_pupil = 7
    else
      minimum = 100
      base_area = 400
      per_pupil = 5
    end

    twice_recommended_size = 2 * (base_area + (per_pupil * number_of_pupils))
    floor_area.between?(minimum, twice_recommended_size)
  end

  def has_configured_school_times?
    school_times.where(usage_type: :school_day).where.not(opening_time: 850).any? || school_times.where(usage_type: :school_day).where.not(closing_time: 1520).any?
  end

  def has_community_use?
    school_times.where(usage_type: :community_use).any?
  end

  def has_solar_configuration?
    meters.active.with_active_meter_attributes(%w[solar_pv_mpan_meter_mapping solar_pv]).any?
  end

  def has_storage_heater_configuration?
    meters.active.with_active_meter_attributes(%w[storage_heaters]).any?
  end

  def needs_solar_configuration?
    return false unless indicated_has_solar_panels?

    !has_solar_configuration?
  end

  def needs_storage_heater_configuration?
    return false unless indicated_has_storage_heaters?

    !has_storage_heater_configuration?
  end

  # Estimated ranges based on what seems sensible for different school types looking
  # across the registered schools
  def pupil_numbers_ok?
    return true unless number_of_pupils

    case school_type
    when 'infant', 'primary'
      number_of_pupils.between?(10, 800)
    when 'junior'
      number_of_pupils.between?(10, 1000)
    when 'middle'
      number_of_pupils.between?(250, 1000)
    when 'mixed_primary_and_secondary'
      number_of_pupils.between?(250, 1500)
    when 'secondary'
      number_of_pupils.between?(250, 1700)
    else
      number_of_pupils.between?(10, 500)
    end
  end

  def self.from_onboarding(onboarding)
    est = Lists::Establishment.current_establishment_from_urn(onboarding.urn)

    sch = new({
                data_enabled: false,
                name: onboarding.school_name,
                establishment: est,
                urn: onboarding.urn,
                full_school: onboarding.full_school
              })

    return sch if sch.establishment.nil?

    sch.assign_attributes({
                            urn: sch.establishment_id,
                            name: est.establishment_name,
                            address: address_from_establishment(est),
                            postcode: est.postcode,
                            website: est.school_website,
                            school_type: school_type_from_phase_of_education_code(est.phase_of_education_code),
                            number_of_pupils: est.number_of_pupils,
                            percentage_free_school_meals: est.percentage_fsm,
                            region: GOR_CODE_TO_REGION[est.gor_code],
                            country: est.gor_code == 'W' ? :wales : :england,
                            local_authority_area: LocalAuthorityArea.find_by(code: est.district_administrative_code)
                          })

    sch
  end

  # Any combinations of these five columns might be empty
  # Formatting is the same as on the GIAS website, except for postcode after county name
  def self.address_from_establishment(est)
    concatenate_address([est.street, est.locality, est.address3, est.town, est.county_name])
  end

  def self.concatenate_address(elements)
    elements.filter(&:present?).join(', ')
  end

  #
  # TODO - finish mapping phases of education from establishment data
  #
  def self.school_type_from_phase_of_education_code(poe_code)
    case poe_code
    when 2 # "Primary"
      school_types[:primary]
    when 3 # "Middle deemed primary"
      school_types[:middle]
    when 4 # "Secondary"
      school_types[:secondary]
    when 5 # "Middle deemed secondary"
      school_types[:middle]
    end
    # otherwise - 0 - "Not applicable"
    # TODO
    # 1 - "Nursery"
    # 6 - "16 plus"
    # 7 - "All-through"
  end

  private

  def valid_uk_postcode
    return unless latitude.blank? || longitude.blank? || country.blank?

    errors.add(:postcode, I18n.t('schools.school_details.geocode_not_found_message'))
  end

  def update_local_distribution_zone
    self.local_distribution_zone_id = LocalDistributionZonePostcode.zone_id_for_school(self)
  end

  def sync_organisation_grouping_from_legacy
    return unless school_group_id.present?

    existing = SchoolGrouping.find_by(school_id: id, role: 'organisation')
    if existing
      existing.update(school_group_id: school_group_id)
    else
      SchoolGrouping.create(school_id: id, school_group_id: school_group_id, role: 'organisation')
    end
  end
end

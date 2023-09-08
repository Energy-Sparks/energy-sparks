# == Schema Information
#
# Table name: schools
#
#  activation_date                              :date
#  active                                       :boolean          default(TRUE)
#  address                                      :text
#  alternative_heating_biomass                  :boolean          default(FALSE), not null
#  alternative_heating_biomass_notes            :text
#  alternative_heating_biomass_percent          :integer          default(0)
#  alternative_heating_district_heating         :boolean          default(FALSE), not null
#  alternative_heating_district_heating_notes   :text
#  alternative_heating_district_heating_percent :integer          default(0)
#  alternative_heating_lpg                      :boolean          default(FALSE), not null
#  alternative_heating_lpg_notes                :text
#  alternative_heating_lpg_percent              :integer          default(0)
#  alternative_heating_oil                      :boolean          default(FALSE), not null
#  alternative_heating_oil_notes                :text
#  alternative_heating_oil_percent              :integer          default(0)
#  bill_requested                               :boolean          default(FALSE)
#  bill_requested_at                            :datetime
#  calendar_id                                  :bigint(8)
#  chart_preference                             :integer          default("default"), not null
#  cooks_dinners_for_other_schools              :boolean          default(FALSE), not null
#  cooks_dinners_for_other_schools_count        :integer
#  cooks_dinners_onsite                         :boolean          default(FALSE), not null
#  country                                      :integer          default("england"), not null
#  created_at                                   :datetime         not null
#  dark_sky_area_id                             :bigint(8)
#  data_enabled                                 :boolean          default(FALSE)
#  enable_targets_feature                       :boolean          default(TRUE)
#  floor_area                                   :decimal(, )
#  funding_status                               :integer          default("state_school"), not null
#  has_swimming_pool                            :boolean          default(FALSE), not null
#  id                                           :bigint(8)        not null, primary key
#  indicated_has_solar_panels                   :boolean          default(FALSE), not null
#  indicated_has_storage_heaters                :boolean          default(FALSE)
#  latitude                                     :decimal(10, 6)
#  level                                        :integer          default(0)
#  local_authority_area_id                      :bigint(8)
#  longitude                                    :decimal(10, 6)
#  met_office_area_id                           :bigint(8)
#  name                                         :string
#  number_of_pupils                             :integer
#  percentage_free_school_meals                 :integer
#  postcode                                     :string
#  process_data                                 :boolean          default(FALSE)
#  public                                       :boolean          default(TRUE)
#  region                                       :integer
#  removal_date                                 :date
#  school_group_cluster_id                      :bigint(8)
#  school_group_id                              :bigint(8)
#  school_type                                  :integer          not null
#  scoreboard_id                                :bigint(8)
#  serves_dinners                               :boolean          default(FALSE), not null
#  slug                                         :string
#  solar_pv_tuos_area_id                        :bigint(8)
#  temperature_area_id                          :bigint(8)
#  template_calendar_id                         :integer
#  updated_at                                   :datetime         not null
#  urn                                          :integer          not null
#  validation_cache_key                         :string           default("initial")
#  visible                                      :boolean          default(FALSE)
#  weather_station_id                           :bigint(8)
#  website                                      :string
#
# Indexes
#
#  index_schools_on_calendar_id              (calendar_id)
#  index_schools_on_latitude_and_longitude   (latitude,longitude)
#  index_schools_on_local_authority_area_id  (local_authority_area_id)
#  index_schools_on_school_group_cluster_id  (school_group_cluster_id)
#  index_schools_on_school_group_id          (school_group_id)
#  index_schools_on_scoreboard_id            (scoreboard_id)
#  index_schools_on_urn                      (urn) UNIQUE
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

  class ProcessDataError < StandardError; end

  friendly_id :slug_candidates, use: [:finders, :slugged, :history]

  delegate :holiday_approaching?, :next_holiday, to: :calendar

  has_and_belongs_to_many :key_stages, join_table: :school_key_stages

  has_many :users
  has_many :meters,               inverse_of: :school
  has_many :cads,                 inverse_of: :school
  has_many :school_times,         inverse_of: :school
  has_many :activities,           inverse_of: :school
  has_many :contacts,             inverse_of: :school
  has_many :observations,         inverse_of: :school
  has_many :transport_surveys,    inverse_of: :school
  has_many :consent_documents,    inverse_of: :school
  has_many :meter_attributes,     inverse_of: :school, class_name: 'SchoolMeterAttribute'
  has_many :consent_grants,       inverse_of: :school
  has_many :meter_reviews,        inverse_of: :school
  has_many :school_targets,       inverse_of: :school
  has_many :school_target_events, inverse_of: :school
  has_many :audits,               inverse_of: :school

  has_many :programmes,               inverse_of: :school
  has_many :programme_activity_types, through: :programmes, source: :activity_types

  has_many :alerts,                                   inverse_of: :school
  has_many :content_generation_runs,                  inverse_of: :school
  has_many :alert_generation_runs,                    inverse_of: :school
  has_many :subscription_generation_runs,             inverse_of: :school
  has_many :benchmark_result_school_generation_runs,  inverse_of: :school
  has_many :analysis_pages, through: :content_generation_runs

  has_many :low_carbon_hub_installations, inverse_of: :school
  has_many :solar_edge_installations, inverse_of: :school
  has_many :rtone_variant_installations, inverse_of: :school

  has_many :equivalences

  has_many :locations

  has_one :dashboard_message, as: :messageable, dependent: :destroy
  has_many :issues, as: :issueable, dependent: :destroy

  has_many :simulations, inverse_of: :school

  has_many :estimated_annual_consumptions

  has_many :amr_data_feed_readings,       through: :meters
  has_many :amr_validated_readings,       through: :meters
  has_many :alert_subscription_events,    through: :contacts

  has_many :school_alert_type_exclusions, dependent: :destroy
  has_many :school_batch_runs

  has_many :advice_page_school_benchmarks

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

  belongs_to :funder, optional: true

  has_one :school_onboarding
  has_one :configuration, class_name: 'Schools::Configuration'

  has_and_belongs_to_many :cluster_users, class_name: "User", join_table: :cluster_schools_users

  has_many :school_partners, -> { order(position: :asc) }
  has_many :partners, through: :school_partners
  accepts_nested_attributes_for :school_partners, reject_if: proc {|attributes| attributes['position'].blank?}

  enum school_type: [:primary, :secondary, :special, :infant, :junior, :middle, :mixed_primary_and_secondary]

  enum chart_preference: [:default, :carbon, :usage, :cost]
  enum country: [:england, :scotland, :wales]
  enum funding_status: [:state_school, :private_school]
  enum region: [:north_east, :north_west, :yorkshire_and_the_humber, :east_midlands, :west_midlands, :east_of_england, :london, :south_east, :south_west]

  scope :active,             -> { where(active: true) }
  scope :inactive,           -> { where(active: false) }
  scope :visible,            -> { active.where(visible: true) }
  scope :not_visible,        -> { active.where(visible: false) }
  scope :process_data,       -> { active.where(process_data: true) }
  scope :data_enabled,       -> { active.where(data_enabled: true) }
  scope :without_group,      -> { active.where(school_group_id: nil) }
  scope :without_scoreboard, -> { active.where(scoreboard_id: nil) }
  scope :awaiting_activation, -> { active.where("visible = ? or data_enabled = ?", false, false) }
  scope :data_visible,        -> { data_enabled.visible }

  scope :with_config, -> { joins(:configuration) }
  scope :by_name,     -> { order(name: :asc) }

  scope :not_in_cluster, -> { where(school_group_cluster_id: nil) }

  validates_presence_of :urn, :name, :address, :postcode, :website, :school_type
  validates_uniqueness_of :urn
  validates :floor_area, :number_of_pupils, :cooks_dinners_for_other_schools_count, numericality: { greater_than: 0, allow_blank: true }
  validates :cooks_dinners_for_other_schools_count, presence: true, if: :cooks_dinners_for_other_schools?
  validates :country, inclusion: { in: countries }
  validates :funding_status, inclusion: { in: funding_statuses }

  validates :percentage_free_school_meals, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100, allow_blank: true }
  #simplified pattern from: https://stackoverflow.com/questions/164979/regex-for-matching-uk-postcodes
  #adjusted to use \A and \z
  validates :postcode, format: { with: /\A[A-Z]{1,2}\d[A-Z\d]? ?\d[A-Z]{2}\z/i }

  validates_associated :school_times, on: :school_time_update

  validates :alternative_heating_oil_percent, :alternative_heating_lpg_percent, :alternative_heating_biomass_percent, :alternative_heating_district_heating_percent, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100, allow_blank: true }

  accepts_nested_attributes_for :school_times, reject_if: proc {|attributes| attributes['day'].blank? }, allow_destroy: true

  auto_strip_attributes :name, :website, :postcode, squish: true

  geocoded_by :postcode do |obj, results|
    if (geo = results.first)
      obj.latitude = geo.data['latitude']
      obj.longitude = geo.data['longitude']
      obj.country = geo.data['country'].downcase
    end
  end

  after_validation :geocode, if: ->(school) { school.postcode.present? && school.postcode_changed? }

  # Note that saved_change_to_activation_date? is a magic ActiveRecord method
  # https://api.rubyonrails.org/classes/ActiveRecord/AttributeMethods/Dirty.html#method-i-will_save_change_to_attribute-3F
  after_save :add_joining_observation, if: proc { saved_change_to_activation_date?(from: nil) }

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
      [:postcode, :name],
      [:urn, :name]
    ]
  end

  def academic_year_for(date)
    return nil unless calendar.present?
    calendar.academic_year_for(date)
  end

  def activities_in_academic_year(date)
    if (academic_year = academic_year_for(date))
      return activities.between(academic_year.start_date, academic_year.end_date).order(created_at: :asc)
    end
    []
  end

  def observations_in_academic_year(date)
    if (academic_year = academic_year_for(date))
      return observations.between(academic_year.start_date, academic_year.end_date).order(created_at: :asc)
    end
    []
  end

  def intervention_types_in_academic_year(date)
    if (observations = observations_in_academic_year(date))
      return observations.map(&:intervention_type).compact
    end
    []
  end

  def intervention_types_by_date
    observations.by_date.map(&:intervention_type).compact
  end

  def national_calendar
    calendar.based_on.based_on
  end

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

  def fuel_types_for_analysis
    configuration.fuel_types_for_analysis
  end

  def has_solar_pv?
    configuration.has_solar_pv
  end

  def has_storage_heaters?
    configuration.has_storage_heaters
  end

  def has_live_data?
    cads.active.any?
  end

  def school_admin
    users.school_admin
  end

  def staff
    users.staff
  end

  def all_school_admins
    school_admin + cluster_users
  end

  def all_adult_school_users
    (all_school_admins + staff).uniq
  end

  def activation_users
    users = []
    if school_onboarding && school_onboarding.created_user.present?
      users << school_onboarding.created_user
    end
    #also email admin, staff and group users
    users += all_adult_school_users.to_a
    users.uniq
  end

  def latest_content
    content_generation_runs.order(created_at: :desc).first
  end

  def latest_dashboard_alerts
    if latest_content
      latest_content.dashboard_alerts
    else
      DashboardAlert.none
    end
  end

  def authenticate_pupil(pupil_password)
    users.pupil.to_a.find {|user| user.pupil_password.casecmp?(pupil_password) }
  end

  def filterable_meters
    if has_solar_pv? || has_storage_heaters?
      Meter.none
    else
      active_meters.real
    end
  end

  def latest_management_priorities
    if latest_content
      latest_content.management_priorities
    else
      ManagementPriority.none
    end
  end

  def latest_analysis_pages
    if latest_content
      latest_content.analysis_pages
    else
      AnalysisPage.none
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
    school_targets.by_start_date.select(&:current?).first
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
    has_expired_target? && expired_target.try(fuel_type).present?
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
    #use the current target if we have one, otherwise the most current target
    #based on start date. So if target as expired, then progress pages still work
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
    all_attributes = [school_group_pseudo_meter_attributes, pseudo_meter_attributes, school_target_attributes, estimated_annual_consumption_meter_attributes].inject(global_pseudo_meter_attributes) do |collection, pseudo_attributes|
      pseudo_attributes.each do |meter_type, attributes|
        collection[meter_type] ||= []
        collection[meter_type] = collection[meter_type] + attributes
      end
      collection
    end

    return all_attributes unless EnergySparks::FeatureFlags.active?(:new_energy_tariff_editor)

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
    all_pseudo_meter_attributes.inject({}) do |collection, (meter_type, attributes)|
      collection[meter_type.to_sym] = MeterAttribute.to_analytics(attributes)
      collection
    end
  end

  def meter_attributes_to_analytics
    meters.order(:mpan_mprn).inject({}) do |collection, meter|
      collection[meter.mpan_mprn] = meter.meter_attributes_to_analytics
      collection
    end
  end

  def invalidate_cache_key
    update_attribute(:validation_cache_key, SecureRandom.uuid)
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

  def all_partners
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
    { active: self.visible.count, data_visible: self.data_visible.count, invisible: self.not_visible.count, removed: self.inactive.count }
  end

  def email_locales
    country == 'wales' ? [:en, :cy] : [:en]
  end

  def subscription_frequency
    if holiday_approaching?
      [:weekly, :termly, :before_each_holiday]
    else
      [:weekly]
    end
  end

  def recent_usage
    Schools::ManagementTableService.new(self)&.management_data&.by_fuel_type_table || OpenStruct.new
  end

  def all_data_sources(meter_type)
    meters.active.where(meter_type: meter_type).data_source_known.joins(:data_source).order("data_sources.name ASC").distinct.pluck("data_sources.name")
  end

  def all_procurement_routes(meter_type)
    meters.active.where(meter_type: meter_type).procurement_route_known.joins(:procurement_route).order("procurement_routes.organisation_name ASC").distinct.pluck("procurement_routes.organisation_name")
  end

  def school_group_cluster_name
    school_group_cluster.try(:name) || I18n.t('common.labels.not_set')
  end

  def parent_tariff_holder
    school_group.present? ? school_group : SiteSettings.current
  end

  def energy_tariff_meter_attributes(meter_type = EnergyTariff.meter_types.keys, applies_to = :both)
    raise InvalidAppliesToError unless EnergyTariff.applies_tos.key?(applies_to.to_s)

    applies_to_keys = [:both, applies_to].uniq

    energy_tariffs.where(meter_type: meter_type).left_joins(:meters).where(meters: { id: nil }, applies_to: applies_to_keys).usable.map(&:meter_attribute)
  end

  def holds_tariffs_of_type?(meter_type)
    Meter::MAIN_METER_TYPES.include?(meter_type.to_sym) && meters.where(meter_type: meter_type).any?
  end

  private

  def add_joining_observation
    observations.create!(
      observation_type: :event,
      description: "#{name} became an active user of Energy Sparks!",
      at: Time.zone.now
    )
  end
end

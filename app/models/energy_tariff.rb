# == Schema Information
#
# Table name: energy_tariffs
#
#  applies_to         :integer          default("both")
#  ccl                :boolean          default(FALSE)
#  created_at         :datetime         not null
#  created_by_id      :bigint(8)
#  enabled            :boolean          default(TRUE)
#  end_date           :date
#  id                 :bigint(8)        not null, primary key
#  meter_type         :integer          default("electricity"), not null
#  name               :text             not null
#  source             :integer          default("manually_entered"), not null
#  start_date         :date
#  tariff_holder_id   :bigint(8)
#  tariff_holder_type :string
#  tariff_type        :integer          default("flat_rate"), not null
#  tnuos              :boolean          default(FALSE)
#  updated_at         :datetime         not null
#  updated_by_id      :bigint(8)
#  vat_rate           :integer
#
# Indexes
#
#  index_energy_tariffs_on_created_by_id                            (created_by_id)
#  index_energy_tariffs_on_tariff_holder_type_and_tariff_holder_id  (tariff_holder_type,tariff_holder_id)
#  index_energy_tariffs_on_updated_by_id                            (updated_by_id)
#
# Foreign Keys
#
#  fk_rails_...  (created_by_id => users.id)
#  fk_rails_...  (updated_by_id => users.id)
#
class EnergyTariff < ApplicationRecord
  belongs_to :tariff_holder, polymorphic: true

  # Declaring associations allows us to use .joins(:school) or .joins(:school_group)
  belongs_to :school, lambda {
    where(energy_tariffs: { tariff_holder_type: 'School' })
  }, foreign_key: 'tariff_holder_id', optional: true
  belongs_to :school_group, lambda {
    where(energy_tariffs: { tariff_holder_type: 'SchoolGroup' })
  }, foreign_key: 'tariff_holder_id', optional: true

  delegated_type :tariff_holder, types: %w[SiteSettings School SchoolGroup]

  has_many :energy_tariff_prices, inverse_of: :energy_tariff, dependent: :destroy
  has_many :energy_tariff_charges, inverse_of: :energy_tariff, dependent: :destroy

  # only populated if tariff_holder is school
  has_and_belongs_to_many :meters, inverse_of: :energy_tariffs

  belongs_to :created_by, optional: true, class_name: 'User'
  belongs_to :updated_by, optional: true, class_name: 'User'

  enum :source, { manually_entered: 0, dcc: 1 }
  enum :meter_type, { electricity: 0, gas: 1, solar_pv: 2, exported_solar_pv: 3 }
  enum :tariff_type, { flat_rate: 0, differential: 1 }

  # Used as an all_energy_tariff_attributes filter:
  # :half_hourly applies to meters which have a :meter_system of :hh
  # :non_half_hourly applies to meters which have a :meter_system of :nhh_amr, :nhh or :smets2_smart
  # :both applies to meters with all meter :system_type values
  enum :applies_to, { both: 0, half_hourly: 1, non_half_hourly: 2 }

  validates :name, presence: true
  validates :vat_rate, numericality: { greater_than_or_equal_to: 0.0, less_than_or_equal_to: 100.0, allow_nil: true }
  validates :applies_to, presence: true

  validate :start_and_end_date_are_not_both_blank
  validate :start_date_is_earlier_than_or_equal_to_end_date
  validate :applies_to_is_set_to_both, unless: :electricity?

  scope :enabled, -> { where(enabled: true) }
  scope :disabled, -> { where(enabled: false) }

  scope :by_name,       -> { order(name: :asc) }
  scope :by_start_date, -> { order(start_date: :asc) }

  # Sorts with null start date first, then start date, then end date
  scope :by_start_and_end, lambda {
    order(Arel.sql('(CASE WHEN start_date is NULL THEN 0 ELSE 1 END) ASC, start_date asc, end_date asc'))
  }

  scope :count_by_school_group, -> { enabled.joins(:school_group).group(:slug).count(:id) }

  scope :for_schools_in_group, lambda { |school_group, source = :manually_entered|
    enabled.where(source:).joins(:school).where({ schools: { active: true, school_group: } })
  }

  scope :count_schools_with_tariff_by_group, lambda { |school_group, source = :manually_entered|
    for_schools_in_group(school_group, source).select(:tariff_holder_id).distinct.count
  }

  scope :latest_with_fixed_end_date, lambda { |meter_type, source = :manually_entered|
    where(meter_type:, source:).where.not(end_date: nil).order(end_date: :desc)
  }

  def applies_to_is_set_to_both
    return if electricity?
    return if both?

    errors.add(:applies_to, I18n.t('schools.user_tariffs.form.errors.applies_to.must_be_set_to_both'))
  end

  def self.usable
    select(&:usable?)
  end

  def usable?
    case tariff_type
    when 'differential' then usable_differential_tariff?
    when 'flat_rate' then usable_flat_rate_tariff?
    end
  end

  def flat_rate?
    tariff_type == 'flat_rate'
  end

  def meter_attribute
    MeterAttribute.new(attribute_type: :accounting_tariff_generic, input_data: to_hash)
  end

  def to_hash
    rates = rates_attrs
    {
      start_date: (start_date || Date.new(2000, 1, 1)).to_fs(:es_compact),
      end_date: (end_date || Date.new(2050, 1, 1)).to_fs(:es_compact),
      source: source.to_sym,
      name:,
      type: flat_rate? ? :flat : :differential,
      sub_type: '',
      rates:,
      vat: vat_rate.nil? ? nil : "#{vat_rate}%",
      climate_change_levy: ccl,
      asc_limit_kw: (value_for_charge(:asc_limit_kw) if rates_has_availability_charge?(rates)),
      tariff_holder: tariff_holder_symbol,
      created_at: created_at.to_datetime
    }.compact
  end

  def value_for_charge(type)
    return unless (charge = energy_tariff_charges.for_type(type).first)

    charge.value.to_s
  end

  def energy_tariff_refers_to_all_meters?
    tariff_holder.site_settings? || tariff_holder.school_group? || meters.empty?
  end

  # Used to the show page to decide whether there's content for the standing
  # charge section which groups these together
  def has_any_standing_charges?
    energy_tariff_charges.any? || tnuos? || vat_rate.present? || ccl?
  end

  private

  def usable_flat_rate_tariff?
    # For a flate rate energy tariff to be considered "usable":
    # * it must have only one energy tariff price record
    # * the price record must have a value set greater than zero
    return true if energy_tariff_prices.count == 1 && energy_tariff_prices&.first&.value&.nonzero?

    false
  end

  def usable_differential_tariff?
    # For a differential rate energy tariff to be considered "usable":
    # * it must have more two or more energy tariff price records
    # * the energy tariff price records combined start and end times must cover a full 24 hour period (1440 minutes)
    # * all energy tariff price records must have values set greater than zero
    return true if energy_tariff_prices.count >= 2 && energy_tariff_prices.complete? && energy_tariff_prices&.map(&:value)&.all? do |value|
      value&.nonzero?
    end

    false
  end

  def start_and_end_date_are_not_both_blank
    return unless tariff_holder_type == 'SchoolGroup'
    return if start_date.present? || end_date.present?

    errors.add(:start_date, I18n.t('schools.user_tariffs.form.errors.dates.start_and_end_date_can_not_both_be_empty'))
    errors.add(:end_date, I18n.t('schools.user_tariffs.form.errors.dates.start_and_end_date_can_not_both_be_empty'))
  end

  def start_date_is_earlier_than_or_equal_to_end_date
    return unless start_date.present? && end_date.present?
    return unless start_date > end_date

    errors.add(:start_date,
               I18n.t('schools.user_tariffs.form.errors.dates.start_date_must_be_earlier_than_or_equal_to_end_date'))
  end

  def tariff_holder_symbol
    meters.any? ? :meter : tariff_holder_type&.underscore&.to_sym
  end

  def rates_attrs
    attrs = {}
    if flat_rate?
      if (first_price = energy_tariff_prices.first)
        attrs[:flat_rate] = { rate: first_price.value.to_s, per: first_price.units.to_s }
      end
    else
      energy_tariff_prices.each_with_index do |price, idx|
        attrs[:"rate#{idx}"] =
          { rate: price.value.to_s, per: price.units.to_s, from: hour_minutes(price.start_time),
            to: hour_minutes(price.end_time.advance(minutes: -30)) }
      end
    end
    energy_tariff_charges.select { |c| c.units.present? }.each do |charge|
      charge_value = { rate: charge.value.to_s, per: charge.units.to_s }
      charge_type = charge.charge_type.to_sym
      # only add these charges if we also have an asc limit
      if charge.is_type?(%i[agreed_availability_charge excess_availability_charge])
        attrs[charge_type] = charge_value if value_for_charge(:asc_limit_kw).present?
      else
        attrs[charge_type] = charge_value
      end
    end
    energy_tariff_charges.select { |c| c.is_type?(%i[duos_red duos_amber duos_green]) }.each do |charge|
      attrs[charge.charge_type.to_sym] = charge.value.to_s
    end
    attrs[:tnuos] = tnuos
    attrs
  end

  def rates_has_availability_charge?(rates)
    rates.key?(:agreed_availability_charge) || rates.key?(:excess_availability_charge)
  end

  def hour_minutes(time)
    hm = time.to_fs(:time).split(':')
    {
      hour: hm.first,
      minutes: hm.last
    }
  end
end

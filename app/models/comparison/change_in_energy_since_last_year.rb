# == Schema Information
#
# Table name: comparison_change_in_energy_since_last_years
#
#  electricity_current_period_co2     :float
#  electricity_current_period_gbp     :float
#  electricity_current_period_kwh     :float
#  electricity_previous_period_co2    :float
#  electricity_previous_period_gbp    :float
#  electricity_previous_period_kwh    :float
#  electricity_tariff_has_changed     :boolean
#  gas_current_period_co2             :float
#  gas_current_period_gbp             :float
#  gas_current_period_kwh             :float
#  gas_previous_period_co2            :float
#  gas_previous_period_gbp            :float
#  gas_previous_period_kwh            :float
#  gas_tariff_has_changed             :boolean
#  id                                 :bigint(8)
#  school_id                          :bigint(8)
#  solar_pv_current_period_co2        :float
#  solar_pv_current_period_kwh        :float
#  solar_pv_previous_period_co2       :float
#  solar_pv_previous_period_kwh       :float
#  solar_type                         :text
#  storage_heater_current_period_co2  :float
#  storage_heater_current_period_gbp  :float
#  storage_heater_current_period_kwh  :float
#  storage_heater_previous_period_co2 :float
#  storage_heater_previous_period_gbp :float
#  storage_heater_previous_period_kwh :float
#
# Indexes
#
#  idx_on_school_id_ef404854ff  (school_id) UNIQUE
#
class Comparison::ChangeInEnergySinceLastYear < Comparison::View
  include MultipleFuelComparisonView

  DEFAULT_FUEL_TYPES = %i[electricity gas storage_heater solar_pv].freeze

  def any_tariff_changed?
    electricity_tariff_has_changed || gas_tariff_has_changed
  end

  # For CSV export
  def fuel_type_names
    codes = []
    codes << I18n.t('common.electricity') if electricity_previous_period_kwh
    codes << I18n.t('common.gas') if gas_previous_period_kwh
    codes << I18n.t('common.storage_heaters') if storage_heater_previous_period_kwh
    codes << I18n.t('common.solar_pv') if solar_type.present?
    codes.join(';')
  end

  scope :with_consistent_fuels_across_periods, -> do
    electricity_and_gas_both_years = '(electricity_previous_period_kwh IS NOT NULL AND electricity_current_period_kwh IS NOT NULL AND gas_previous_period_kwh IS NOT NULL and gas_current_period_kwh IS NOT NULL)'
    electricity_only_both_years = '(electricity_previous_period_kwh IS NOT NULL AND electricity_current_period_kwh IS NOT NULL AND gas_previous_period_kwh IS NULL and gas_current_period_kwh IS NULL)'
    gas_only_both_years = '(electricity_previous_period_kwh IS NULL AND electricity_current_period_kwh IS NULL AND gas_previous_period_kwh IS NOT NULL and gas_current_period_kwh IS NOT NULL)'
    where("(#{electricity_and_gas_both_years} OR #{electricity_only_both_years} OR #{gas_only_both_years})")
  end

  scope :by_total_percentage_change, -> do
    by_percentage_change_across_fields(
      [:electricity_previous_period_kwh, :gas_previous_period_kwh, :storage_heater_previous_period_kwh, :solar_pv_previous_period_kwh],
      [:electricity_current_period_kwh, :gas_current_period_kwh, :storage_heater_current_period_kwh, :solar_pv_current_period_kwh]
    )
  end

  def total_previous_period(unit: :kwh)
    all_previous_period(unit: unit).sum(&:to_f)
  end

  # Override this. The underlying alert doesn't generate variables for
  # solar costs as we don't have that data. So if the unit is gbp and
  # fuel is solar then skip
  def field_names(period: :previous_period, unit: :kwh)
    unit = :gbp if unit == :£
    field_names = []
    fuel_types.each do |fuel_type|
      field_names << field_name(fuel_type, period, unit) unless unit == :gbp && fuel_type == :solar_pv
    end
    field_names
  end

  private

  def fuel_types
    DEFAULT_FUEL_TYPES
  end
end

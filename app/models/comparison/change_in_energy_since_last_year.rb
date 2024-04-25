# == Schema Information
#
# Table name: change_in_energy_since_last_years
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
#  solar_pv_current_period_gbp        :float
#  solar_pv_current_period_kwh        :float
#  solar_pv_previous_period_co2       :float
#  solar_pv_previous_period_gbp       :float
#  solar_pv_previous_period_kwh       :float
#  solar_type                         :text
#  storage_heater_current_period_co2  :float
#  storage_heater_current_period_gbp  :float
#  storage_heater_current_period_kwh  :float
#  storage_heater_previous_period_co2 :float
#  storage_heater_previous_period_gbp :float
#  storage_heater_previous_period_kwh :float
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
    codes << I18n.t('common.solar_pv') if enba_solr.present?
    codes.join(';')
  end

  scope :with_total_that_covers_both_periods, -> do
    where('((electricity_previous_period_kwh IS NOT NULL AND electricity_current_period_kwh IS NOT NULL AND gas_previous_period_kwh IS NOT NULL and gas_current_period_kwh IS NOT NULL)
OR (electricity_previous_period_kwh IS NOT NULL AND electricity_current_period_kwh IS NOT NULL AND gas_previous_period_kwh IS NULL and gas_current_period_kwh IS NULL)
OR (electricity_previous_period_kwh IS NULL AND electricity_current_period_kwh IS NULL AND gas_previous_period_kwh IS NOT NULL and gas_current_period_kwh IS NOT NULL))')
  end
  scope :with_data_for_previous_period, -> do
    where_any_present(
      [:electricity_previous_period_kwh, :gas_previous_period_kwh, :storage_heater_previous_period_kwh, :solar_pv_previous_period_kwh]
    )
  end

  scope :by_total_percentage_change, -> do
    by_percentage_change_across_fields(
      [:electricity_previous_period_kwh, :gas_previous_period_kwh, :storage_heater_previous_period_kwh, :solar_pv_previous_period_kwh],
      [:electricity_current_period_kwh, :gas_current_period_kwh, :storage_heater_current_period_kwh, :solar_pv_current_period_kwh]
    )
  end

  # Orders the results by a percentage change value that is calculated from summing together multiple attributes
  #
  # Uses COALESCE to convert nil values for an attribute to zero (e.g. if a school doesn't have gas or storage heaters)
  #
  # Uses NULLIF to convert a total of 0.0 for a set of attributes to NULL, so the order value becomes NULL.
  # This avoids errors in the calculations. We then sort NULLs last
  scope :by_percentage_change_across_fields, ->(base_val_fields, new_val_fields) do
    order(
      Arel.sql(
        sanitize_sql_array("(NULLIF(#{new_val_fields.map {|v| "COALESCE(#{v}, 0.0)" }.join('+')},0.0) - NULLIF(#{base_val_fields.map {|v| "COALESCE(#{v}, 0.0)" }.join('+')},0.0)) / NULLIF(#{base_val_fields.map {|v| "COALESCE(#{v}, 0.0)" }.join('+')},0.0) ASC NULLS LAST")
      )
    )
  end

  private

  def fuel_types
    DEFAULT_FUEL_TYPES
  end
end

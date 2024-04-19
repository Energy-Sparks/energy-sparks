# == Schema Information
#
# Table name: heat_saver_march_2024s
#
#  activation_date                               :date
#  electricity_current_period_co2                :float
#  electricity_current_period_gbp                :float
#  electricity_current_period_kwh                :float
#  electricity_previous_period_co2               :float
#  electricity_previous_period_gbp               :float
#  electricity_previous_period_kwh               :float
#  electricity_tariff_has_changed                :boolean
#  floor_area_changed                            :boolean
#  gas_current_period_co2                        :float
#  gas_current_period_gbp                        :float
#  gas_current_period_kwh                        :float
#  gas_previous_period_co2                       :float
#  gas_previous_period_gbp                       :float
#  gas_previous_period_kwh                       :float
#  gas_previous_period_kwh_unadjusted            :float
#  gas_tariff_has_changed                        :boolean
#  id                                            :bigint(8)
#  pupils_changed                                :boolean
#  school_id                                     :bigint(8)
#  solar_type                                    :text
#  storage_heater_current_period_co2             :float
#  storage_heater_current_period_gbp             :float
#  storage_heater_current_period_kwh             :float
#  storage_heater_previous_period_co2            :float
#  storage_heater_previous_period_gbp            :float
#  storage_heater_previous_period_kwh            :float
#  storage_heater_previous_period_kwh_unadjusted :float
#  storage_heater_tariff_has_changed             :boolean
#
class Comparison::HeatSaverMarch2024 < Comparison::View
  include MultipleFuelComparisonView
  self.table_name = 'heat_saver_march_2024s'

  def any_tariff_changed?
    electricity_tariff_has_changed ||
      gas_tariff_has_changed ||
      storage_heater_tariff_has_changed
  end

  scope :with_data_for_previous_period, -> do
    where_any_present(
      [:electricity_previous_period_kwh, :gas_previous_period_kwh, :storage_heater_previous_period_kwh]
    )
  end

  scope :by_total_percentage_change do
    by_percentage_change_across_fields(
      [:electricity_previous_period_kwh, :gas_previous_period_kwh, :storage_heater_previous_period_kwh],
      [:electricity_current_period_kwh, :gas_current_period_kwh, :storage_heater_current_period_kwh]
    )
  end

  # E.g. previous_year, current_year
  scope :by_percentage_change_across_fields, ->(base_val_fields, new_val_fields) do
    order(
      Arel.sql(
        sanitize_sql_array("(NULLIF(#{new_val_fields.map {|v| "COALESCE(#{v}, 0.0)" }.join('+')},0.0) - NULLIF(#{base_val_fields.map {|v| "COALESCE(#{v}, 0.0)" }.join('+')},0.0)) / NULLIF(#{base_val_fields.map {|v| "COALESCE(#{v}, 0.0)" }.join('+')},0.0) ASC NULLS FIRST")
      )
    )
  end
end

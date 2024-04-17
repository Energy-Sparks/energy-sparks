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
  self.table_name = 'heat_saver_march_2024s'

  def any_tariff_changed?
    electricity_tariff_has_changed ||
      gas_tariff_has_changed ||
      storage_heater_tariff_has_changed
  end

  def all_previous_period(unit: :kwh)
    field_names(period: :previous_period, unit: unit).map do |field|
      send(field)
    end
  end

  def all_current_period(unit: :kwh)
    field_names(period: :current_period, unit: unit).map do |field|
      send(field)
    end
  end

  private

  def field_names(period: :previous_year, unit: :kwh)
    unit = :gbp if unit == :£
    field_names = []
    %i[electricity gas storage_heater].each do |fuel_type|
      field_names << :"#{fuel_type}_#{period}_#{unit}"
    end
    field_names
  end
end

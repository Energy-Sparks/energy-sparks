# == Schema Information
#
# Table name: change_in_energy_use_since_joined_energy_sparks
#
#  activation_date                    :date
#  activationyear_electricity_note    :text
#  activationyear_gas_note            :text
#  activationyear_storage_heater_note :text
#  electricity_current_period_co2     :float
#  electricity_current_period_gbp     :float
#  electricity_current_period_kwh     :float
#  electricity_previous_period_co2    :float
#  electricity_previous_period_gbp    :float
#  electricity_previous_period_kwh    :float
#  gas_current_period_co2             :float
#  gas_current_period_gbp             :float
#  gas_current_period_kwh             :float
#  gas_previous_period_co2            :float
#  gas_previous_period_gbp            :float
#  gas_previous_period_kwh            :float
#  id                                 :bigint(8)
#  school_id                          :bigint(8)
#  solar_type                         :text
#  storage_heater_current_period_co2  :float
#  storage_heater_current_period_gbp  :float
#  storage_heater_current_period_kwh  :float
#  storage_heater_previous_period_co2 :float
#  storage_heater_previous_period_gbp :float
#  storage_heater_previous_period_kwh :float
#
class Comparison::ChangeInEnergyUseSinceJoinedEnergySparks < Comparison::View
  include MultipleFuelComparisonView
  include ArbitraryPeriodComparisonView

  scope :with_some_data, -> do
    where("COALESCE(activationyear_electricity_note, activationyear_gas_note) IS NOT NULL AND (activationyear_electricity_note NOT IN ('no recent data', 'not enough data') OR activationyear_gas_note NOT IN ('no recent data', 'not enough data'))")
  end

  def pupils_changed
    false
  end

  def floor_area_changed
    false
  end

  def storage_heater_tariff_has_changed
    false
  end

  def electricity_tariff_has_changed
    false
  end

  def gas_tariff_has_changed
    false
  end

  def storage_heater_previous_period_kwh_unadjusted
    nil
  end

  def gas_previous_period_kwh_unadjusted
    nil
  end
end

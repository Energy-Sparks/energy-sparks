# == Schema Information
#
# Table name: comparison_change_in_energy_use_since_joined_energy_sparks
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
# Indexes
#
#  idx_on_school_id_f606257469  (school_id) UNIQUE
#
class Comparison::ChangeInEnergyUseSinceJoinedEnergySparks < Comparison::View
  include MultipleFuelComparisonView
  include ArbitraryPeriodComparisonView

  NO_DATA = [ManagementSummaryTable::NO_RECENT_DATA_MESSAGE, ManagementSummaryTable::NOT_ENOUGH_DATA_MESSAGE].freeze

  scope :with_reportable_data, -> do
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

  private

  # Returns a list of fuel types that have data to be included in the total
  # Fuel types are filtered by value of the note column using values set
  # by the alert.
  def fuel_types
    fuel_types = []
    fuel_types = fuel_types += [:electricity, :storage_heater] unless NO_DATA.include?(activationyear_electricity_note)
    fuel_types << :gas unless NO_DATA.include?(activationyear_gas_note)
    fuel_types
  end
end

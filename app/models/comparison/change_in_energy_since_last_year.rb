# == Schema Information
#
# Table name: change_in_energy_since_last_years
#
#  current_year_electricity_co2      :float
#  current_year_electricity_gbp      :float
#  current_year_electricity_kwh      :float
#  current_year_gas_co2              :float
#  current_year_gas_gbp              :float
#  current_year_gas_kwh              :float
#  current_year_solar_pv_co2         :float
#  current_year_solar_pv_gbp         :float
#  current_year_solar_pv_kwh         :float
#  current_year_storage_heaters_co2  :float
#  current_year_storage_heaters_gbp  :float
#  current_year_storage_heaters_kwh  :float
#  id                                :bigint(8)
#  previous_year_electricity_co2     :float
#  previous_year_electricity_gbp     :float
#  previous_year_electricity_kwh     :float
#  previous_year_gas_co2             :float
#  previous_year_gas_gbp             :float
#  previous_year_gas_kwh             :float
#  previous_year_solar_pv_co2        :float
#  previous_year_solar_pv_gbp        :float
#  previous_year_solar_pv_kwh        :float
#  previous_year_storage_heaters_co2 :float
#  previous_year_storage_heaters_gbp :float
#  previous_year_storage_heaters_kwh :float
#  school_id                         :bigint(8)
#  solar_type                        :text
#
class Comparison::ChangeInEnergySinceLastYear < Comparison::View
  def all_previous_year(unit: :kwh)
    field_names(period: :previous_year, unit: unit).map do |field|
      send(field)
    end
  end

  def all_current_year(unit: :kwh)
    field_names(period: :current_year, unit: unit).map do |field|
      send(field)
    end
  end

  private

  def field_names(period: :previous_year, unit: :kwh)
    unit = :gbp if unit == :£
    field_names = []
    %i[electricity gas storage_heaters solar_pv].each do |fuel_type|
      field_names << :"#{period}_#{fuel_type}_#{unit}"
    end
    field_names
  end
end

# == Schema Information
#
# Table name: annual_energy_costs_per_pupils
#
#  electricity_economic_tariff_changed_this_year :boolean
#  gas_economic_tariff_changed_this_year         :boolean
#  id                                            :bigint(8)
#  one_year_electricity_per_pupil_co2            :float
#  one_year_electricity_per_pupil_gbp            :float
#  one_year_electricity_per_pupil_kwh            :float
#  one_year_gas_per_pupil_co2                    :float
#  one_year_gas_per_pupil_gbp                    :float
#  one_year_gas_per_pupil_kwh                    :float
#  one_year_storage_heater_per_pupil_co2         :float
#  one_year_storage_heater_per_pupil_gbp         :float
#  one_year_storage_heater_per_pupil_kwh         :float
#  school_id                                     :bigint(8)
#
class Comparison::AnnualEnergyCostsPerPupil < Comparison::View
  def kwhs
    [one_year_electricity_per_pupil_kwh, one_year_gas_per_pupil_kwh, one_year_storage_heater_per_pupil_kwh]
  end

  def costs
    [one_year_electricity_per_pupil_gbp, one_year_gas_per_pupil_gbp, one_year_storage_heater_per_pupil_gbp]
  end

  def co2s
    [one_year_electricity_per_pupil_co2, one_year_gas_per_pupil_co2, one_year_storage_heater_per_pupil_co2]
  end
end

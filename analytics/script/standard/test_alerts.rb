require 'require_all'
require_relative '../../lib/dashboard.rb'
require_rel '../../test_support'

# module Logging
#   @logger = Logger.new(File.join('log', "alert #{DateTime.now.strftime('%Y-%m-%d %H%M%S')}.log"))
#   logger.level = :debug
# end

# Romilly, gas
asof_date = Date.new(2025, 4, 4)
schools = ['l*']

# Mallaig, storage/electricity
#asof_date = Date.new(2024, 4, 8)
#schools = ['m*']

# Electricity, Ysgol
# asof_date = Date.new(2024, 3, 24)
# schools = ['y*']

overrides = {
  schools:  schools,
  cache_school: false,
  alerts:   { alerts: nil, control: { asof_date: asof_date} },
  alerts:   { alerts: [
    AlertElectricityBaseloadVersusBenchmark
#    AlertThermostaticControl
#    AlertEnergyAnnualVersusBenchmark,
#    AlertSchoolWeekComparisonGas,
#    AlertOutOfHoursElectricityUsage,
#    AlertElectricityBaseloadVersusBenchmark,
#    AlertHeatingComingOnTooEarly,
#    AlertPreviousYearHolidayComparisonElectricity,
#    AlertSolarPVBenefitEstimator,
#    AlertElectricityAnnualVersusBenchmark,
#    AlertElectricityLongTermTrend,
#    AlertGasAnnualVersusBenchmark,
#    AlertEnergyAnnualVersusBenchmark,
#    AlertElectricityPeakKWVersusBenchmark,
#    AlertElectricityBaseloadVersusBenchmark,
#    AlertSeasonalBaseloadVariation,
#    AlertIntraweekBaseloadVariation,
#    AlertGasAnnualVersusBenchmark,
#    AlertGasLongTermTrend,
#    AlertChangeInElectricityBaseloadShortTerm,
#    AlertPreviousYearHolidayComparisonElectricity,
#    AlertPreviousHolidayComparisonElectricity,
#    AlertOutOfHoursElectricityUsagePreviousYear
#     AlertSolarGeneration
    #AlertEnergyAnnualVersusBenchmark,
    #AlertAdditionalPrioritisationData,
    #AlertHotWaterEfficiency
#    AlertGasHeatingHotWaterOnDuringHoliday,
#    AlertStorageHeaterHeatingOnDuringHoliday,
#    AlertElectricityUsageDuringCurrentHoliday
    ],
  control: { asof_date: asof_date, outputs: %i[raw_variables_for_saving html_template_variables], log: [:invalid_alerts] } },
  no_alerts:   { alerts: [], control: { asof_date: asof_date } }
}

script = RunAlerts.default_config.deep_merge(overrides)

RunTests.new(script).run

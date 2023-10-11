namespace :after_party do
  desc 'Deployment task: assign_advice_page_to_alert_type'
  task assign_advice_page_to_alert_type: :environment do
    puts "Running deploy task 'assign_advice_page_to_alert_type'"

    # Add AdvicePage to Alerts, for linking from dashboard alerts
    ALERTS = {
      'AlertHeatingComingOnTooEarly' => :baseload,
      'AlertHeatingSensitivityAdvice' => :heating_control,
      'AlertHotWaterEfficiency' => :hot_water,
      'AlertOutOfHoursElectricityUsage' => :electricity_out_of_hours,
      'AlertOutOfHoursGasUsage' => :gas_out_of_hours,
      'AlertHotWaterInsulationAdvice' => :hot_water,
      'AlertThermostaticControl' => :thermostatic,
      'AlertElectricityMeterConsolidationOpportunity' => :electricity_costs,
      'AlertGasMeterConsolidationOpportunity' => :gas_costs,
      'AlertMeterASCLimit' => :electricity_costs,
      'AlertStorageHeaterThermostatic' => :storage_heaters,
      'AlertStorageHeaterOutOfHours' => :storage_heaters,
      'AlertSolarPVBenefitEstimator' => :solar_pv,
      'AlertElectricityLongTermTrend' => :electricity_long_term,
      'AlertGasLongTermTrend' => :gas_long_term,
      'AlertStorageHeatersLongTermTrend' => :storage_heaters,
      'AlertOptimumStartAnalysis' => :heating_control,
      'AlertChangeInElectricityBaseloadShortTerm' => :baseload,
      'AlertWeekendGasConsumptionShortTerm' => :gas_out_of_hours,
      'AlertSchoolWeekComparisonElectricity' => :electricity_recent_changes,
      'AlertPreviousHolidayComparisonElectricity' => :electricity_out_of_hours,
      'AlertPreviousYearHolidayComparisonElectricity' => :electricity_out_of_hours,
      'AlertSchoolWeekComparisonGas' => :gas_recent_changes,
      'AlertPreviousHolidayComparisonGas' => :gas_out_of_hours,
      'AlertSeasonalBaseloadVariation' => :baseload,
      'AlertIntraweekBaseloadVariation' => :baseload,
      'AlertSeasonalHeatingSchoolDays' => :gas_out_of_hours,
      'AlertSeasonalHeatingSchoolDaysStorageHeaters' => :storage_heaters,
      'AlertElectricityUsageDuringCurrentHoliday' => :electricity_out_of_hours,
      'AlertGasHeatingHotWaterOnDuringHoliday' => :gas_out_of_hours,
      'AlertStorageHeaterHeatingOnDuringHoliday' => :storage_heaters,
      'AlertTurnHeatingOff' => :heating_control,
      'AlertTurnHeatingOffStorageHeaters' => :storage_heaters,
      'AlertEnergyAnnualVersusBenchmark' => :total_energy_use,
      'AlertElectricityAnnualVersusBenchmark' => :electricity_long_term,
      'AlertElectricityBaseloadVersusBenchmark' => :baseload,
      'AlertGasAnnualVersusBenchmark' => :gas_long_term,
      'AlertElectricityPeakKWVersusBenchmark' => :electricity_intraday,
      'AlertStorageHeaterAnnualVersusBenchmark' => :storage_heaters,
      'AlertPreviousYearHolidayComparisonGas' => :gas_out_of_hours
    }.freeze

    ALERTS.each do |clazz, key|
      advice_page = AdvicePage.find_by(key: key)
      AlertType.where(class_name: clazz).update(advice_page: advice_page)
    end

    # Add advice page for analysis pages, to handle redirects
    OLD_ANALYSIS_PAGES = {
      'AdviceGasOutHours' => :gas_out_of_hours,
      'AdviceBenchmark' => :total_energy_use,
      'AdviceGasAnnual' => :gas_long_term,
      'AdviceElectricityAnnual' => :electricity_long_term,
      'AdviceElectricityOutHours' => :electricity_out_of_hours,
      'AdviceElectricityLongTerm' => :electricity_long_term,
      'AdviceElectricityRecent' => :electricity_recent_changes,
      'AdviceGasLongTerm' => :gas_long_term,
      'AdviceGasRecent' => :gas_recent_changes,
      'AdviceGasBoilerMorningStart' => :heating_control,
      'AdviceGasBoilerSeasonalControl' => :heating_control,
      'AdviceGasHotWater' => :hot_water,
      'AdviceEnergyTariffs' => :electricity_costs,
      'AdviceElectricityIntraday' => :electricity_intraday,
      'AdviceGasBoilerFrost' => :heating_control,
      'AdviceStorageHeaters' => :storage_heaters,
      'AdviceSolarPV' => :solar_pv,
      'AdviceGasThermostaticControl' => :thermostatic,
      'AdviceBaseload' => :baseload,
      'AdviceGasCosts' => :gas_costs,
      'AdviceElectricityCosts' => :electricity_costs,
      'AdviceGasMeterBreakdownBase' => :gas_costs,
      'AdviceElectricityMeterBreakdownBase' => :electricity_costs
    }.freeze

    OLD_ANALYSIS_PAGES.each do |clazz, key|
      advice_page = AdvicePage.find_by(key: key)
      AlertType.where(class_name: clazz).update(advice_page: advice_page)
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end

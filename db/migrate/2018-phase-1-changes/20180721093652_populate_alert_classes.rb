class PopulateAlertClasses < ActiveRecord::Migration[5.2]
  def change
    if AlertType.any?
      AlertType.find_by(title: 'Thermostatic Control').update(class_name: 'AlertThermostaticControl')
      AlertType.find_by(title: 'Weekend gas consumption').update(class_name: 'AlertWeekendGasConsumptionShortTerm')
      AlertType.find_by(title: 'Electricity baseload too high').update(class_name: 'AlertElectricityBaseloadVersusBenchmark')
      AlertType.find_by(title: 'Holiday coming up').update(class_name: 'AlertImpendingHoliday')
      AlertType.find_by(title: 'Turn heating on/off').update(class_name: 'AlertHeatingOnOff')
      AlertType.find_by(title: 'Electricity baseload has changed').update(class_name: 'AlertChangeInElectricityBaseloadShortTerm')
      AlertType.find_by(title: 'Electricity consumption has changed').update(class_name: 'AlertChangeInDailyElectricityShortTerm')
      AlertType.find_by(title: 'Electricity out of hours usage too high').update(class_name: 'AlertOutOfHoursElectricityUsage')
      AlertType.find_by(title: 'Gas out of hours usage too high').update(class_name: 'AlertOutOfHoursGasUsage')
      AlertType.find_by(title: 'Electricity usage high').update(class_name: 'AlertElectricityAnnualVersusBenchmark')
      AlertType.find_by(title: 'Gas usage high').update(class_name: 'AlertGasAnnualVersusBenchmark')
      AlertType.find_by(title: 'Heating coming on too early in the morning').update(class_name: 'AlertHeatingComingOnTooEarly')
      AlertType.find_by(title: 'Gas consumption has changed').update(class_name: 'AlertChangeInDailyGasShortTerm')
      AlertType.find_by(title: 'Hot water efficiency').update(class_name: 'AlertHotWaterEfficiency')
    end
  end
end

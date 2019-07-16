# frozen_string_literal: true

namespace :after_party do
  desc 'Deployment task: enable_alert_templates'
  task enable_some_more_alert_templates: :environment do
    puts "Running deploy task 'enable_alert_templates'"

    # Originally enabled
    # AlertChangeInDailyElectricityShortTerm
    # AlertChangeInDailyGasShortTerm
    # AlertChangeInElectricityBaseloadShortTerm
    # AlertOutOfHoursElectricityUsage
    # AlertOutOfHoursGasUsage

    # Failing
    # AlertWeekendGasConsumptionShortTerm
    # AlertHeatingOnOff
    # AlertHotWaterEfficiency
    # AlertThermostaticControl

    ActiveRecord::Base.transaction do
      %w[
        AlertElectricityAnnualVersusBenchmark
        AlertElectricityBaseloadVersusBenchmark
        AlertGasAnnualVersusBenchmark
        AlertHeatingComingOnTooEarly
        AlertHeatingSensitivityAdvice
      ].each do |class_name|
        puts "Enabling variables for #{class_name}"
        AlertType.find_by!(class_name: class_name).update!(has_variables: true)
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: '20190510132347'
  end
end

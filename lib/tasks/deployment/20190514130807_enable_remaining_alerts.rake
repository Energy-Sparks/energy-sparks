# frozen_string_literal: true

namespace :after_party do
  desc 'Deployment task: enable_remaining_alerts'
  task enable_remaining_alerts: :environment do
    puts "Running deploy task 'enable_remaining_alerts'"

    # Put your task implementation HERE.
    ActiveRecord::Base.transaction do
      %w[
        AlertWeekendGasConsumptionShortTerm
        AlertHeatingOnOff
        AlertHotWaterEfficiency
        AlertThermostaticControl
      ].each do |class_name|
        puts "Enabling variables for #{class_name}"
        AlertType.find_by!(class_name: class_name).update!(has_variables: true)
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: '20190514130807'
  end
end

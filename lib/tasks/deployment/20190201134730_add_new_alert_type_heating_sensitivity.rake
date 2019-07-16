# frozen_string_literal: true

namespace :after_party do
  desc 'Deployment task: add_new_alert_type'
  task add_new_alert_type_heating_sensitivity: :environment do
    puts "Running deploy task 'add_new_alert_type Heating Sensitivity Advice'"

    # Put your task implementation HERE.
    AlertType.where(fuel_type: :gas, sub_category: :heating, frequency: :weekly, title: 'Heating Sensitivity Advice', class_name: 'AlertHeatingSensitivityAdvice', show_ratings: true, description: 'Heating Sensitivity Advice').first_or_create
    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: '20190201134730'
  end
end

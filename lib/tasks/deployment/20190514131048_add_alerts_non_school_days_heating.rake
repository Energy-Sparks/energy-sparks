# frozen_string_literal: true

namespace :after_party do
  desc 'Deployment task: add_alerts_non_school_days_heating'
  task add_alerts_non_school_days_heating: :environment do
    puts "Running deploy task 'add_alerts_non_school_days_heating'"

    # Put your task implementation HERE.
    AlertType.create(
      fuel_type: :gas,
      sub_category: :heating,
      frequency: :weekly,
      title: 'Heating on on non school days',
      description: 'Heating on on non school days',
      class_name: 'AlertHeatingOnNonSchoolDays',
      show_ratings: true,
      has_variables: true,
      source: 'analytics'
    )

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: '20190514131048'
  end
end

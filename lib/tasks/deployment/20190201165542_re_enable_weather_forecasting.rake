# frozen_string_literal: true

namespace :after_party do
  desc 'Deployment task: re_enable_weather_forecasting'
  task re_enable_weather_forecasting: :environment do
    puts "Running deploy task 're_enable_weather_forecasting'"

    # Put your task implementation HERE.
    AlertType.find(11).update(fuel_type: :gas)
    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: '20190201165542'
  end
end

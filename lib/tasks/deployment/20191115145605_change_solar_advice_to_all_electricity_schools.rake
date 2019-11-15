namespace :after_party do
  desc 'Deployment task: change_solar_advice_to_all_electricity_schools'
  task change_solar_advice_to_all_electricity_schools: :environment do
    puts "Running deploy task 'change_solar_advice_to_all_electricity_schools'"

    AlertType.find_by(class_name: 'AdviceSolarPV').update(fuel_type: :electricity)

    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end

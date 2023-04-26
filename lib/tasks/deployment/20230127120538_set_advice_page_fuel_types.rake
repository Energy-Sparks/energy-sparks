namespace :after_party do
  desc 'Deployment task: set_advice_page_fuel_types'
  task set_advice_page_fuel_types: :environment do
    puts "Running deploy task 'set_advice_page_fuel_types'"

    ['baseload',
     'electricity_costs',
     'electricity_long_term',
     'electricity_intraday',
     'electricity_out_of_hours',
     'electricity_recent_changes'].each do |key|
      AdvicePage.find_by_key(key).update(fuel_type: :electricity) if AdvicePage.find_by_key(key)
    end

    ['boiler_control',
     'thermostatic_control',
     'gas_costs',
     'gas_long_term',
     'gas_intraday',
     'gas_out_of_hours',
     'gas_recent_changes',
     'hot_water'].each do |key|
      AdvicePage.find_by_key(key).update(fuel_type: :gas) if AdvicePage.find_by_key(key)
    end

    ['storage_heaters'].each do |key|
      AdvicePage.find_by_key(key).update(fuel_type: :storage_heater) if AdvicePage.find_by_key(key)
    end

    ['solar_pv'].each do |key|
      AdvicePage.find_by_key(key).update(fuel_type: :solar_pv) if AdvicePage.find_by_key(key)
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end

namespace :after_party do
  desc 'Deployment task: create_all_advice_pages'
  task create_all_advice_pages: :environment do
    puts "Running deploy task 'create_all_advice_pages'"

    %w[total_energy_use
       baseload
       electricity_costs
       electricity_long_term
       electricity_intraday
       electricity_out_of_hours
       electricity_recent_changes
       boiler_control
       thermostatic_control
       gas_costs
       gas_long_term
       gas_intraday
       gas_out_of_hours
       gas_recent_changes
       hot_water
       solar_pv
       storage_heaters].each do |key|
      AdvicePage.create!(key: key) unless AdvicePage.find_by(key: key)
    end

    %w[gas_costs electricity_costs].each do |key|
      page = AdvicePage.find_by(key: key)
      page.update!(restricted: true) if page.present?
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end

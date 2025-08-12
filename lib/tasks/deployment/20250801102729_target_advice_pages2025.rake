namespace :after_party do
  desc 'Deployment task: target_advice_pages2025'
  task target_advice_pages2025: :environment do
    puts "Running deploy task 'target_advice_pages2025'"
    Flipper.enable_group(:target_advice_pages_2025, :admins)
    AdvicePage.find_or_create_by!(key: :electricity_target, fuel_type: :electricity)
    AdvicePage.find_or_create_by!(key: :gas_target, fuel_type: :gas)
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end

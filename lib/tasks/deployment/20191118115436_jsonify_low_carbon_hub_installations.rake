namespace :after_party do
  desc 'Deployment task: jsonify_low_carbon_hub_installations'
  task jsonify_low_carbon_hub_installations: :environment do
    puts "Running deploy task 'jsonify_low_carbon_hub_installations'"

    LowCarbonHubInstallation.all.each do |installation|
      installation.update!(information: JSON.parse(installation.information))
    end
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end

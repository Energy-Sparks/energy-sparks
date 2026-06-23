# frozen_string_literal: true

namespace :after_party do
  desc 'Deployment task: active_solar_installations'
  task active_solar_installations: :environment do
    puts "Running deploy task 'active_solar_installations'"

    SolarEdgeInstallation.update_all(active: true) # rubocop:disable Rails/SkipsModelValidations
    LowCarbonHubInstallation.update_all(active: true) # rubocop:disable Rails/SkipsModelValidations
    RtoneVariantInstallation.update_all(active: true) # rubocop:disable Rails/SkipsModelValidations
    SolisCloudInstallation.update_all(active: true) # rubocop:disable Rails/SkipsModelValidations
    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end

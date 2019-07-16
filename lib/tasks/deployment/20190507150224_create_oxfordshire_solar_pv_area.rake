# frozen_string_literal: true

namespace :after_party do
  desc 'Deployment task: create_oxfordshire_solar_pv_area'
  task create_oxfordshire_solar_pv_area: :environment do
    puts "Running deploy task 'create_oxfordshire_solar_pv_area'"

    bath_pv_feed = DataFeeds::SolarPvTuos.where(title: 'Solar PV Tuos Bath').first!
    SolarPvTuosArea.create_with(data_feed: bath_pv_feed).find_or_create_by!(title: 'Oxfordshire')

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: '20190507150224'
  end
end

# frozen_string_literal: true

namespace :after_party do
  desc 'Deployment task: group_solar_advice_page_feature'
  task group_solar_advice_page_feature: :environment do
    puts "Running deploy task 'group_solar_advice_page_feature'"

    Flipper.add(:group_solar_advice_page)
    Flipper.enable_group(:group_solar_advice_page, :admins)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end

# frozen_string_literal: true

namespace :after_party do
  desc 'Deployment task: holiday_community_use_alerts'
  task holiday_community_use_alerts: :environment do
    puts "Running deploy task 'holiday_community_use_alerts'"

    require 'dashboard'

    [[AlertElectricityUsageDuringCurrentHoliday, Alerts::Electricity::UsageDuringCurrentHolidayWithCommunityUse],
     [AlertGasHeatingHotWaterOnDuringHoliday, Alerts::Gas::HeatingHotWaterOnDuringHolidayWithCommunityUse],
     [AlertStorageHeaterHeatingOnDuringHoliday, Alerts::StorageHeater::HeatingOnDuringHolidayWithCommunityUse]].each do
      |old_class, new_class|
       type = AlertType.find_by(class_name: old_class.name)
       type = type.dup
       type.title += ' with Community Use'
       type.class_name = new_class.name
       type.enabled = false
       type.save!
     end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end

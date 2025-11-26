namespace :after_party do
  desc 'Deployment task: holiday_community_use_alerts'
  task holiday_community_use_alerts: :environment do
    puts "Running deploy task 'holiday_community_use_alerts'"

    AlertType.find_or_create_by!(class_name: 'Alerts::Electricity::UsageDuringCurrentHolidayWithCommunityUse') do |type|
      type.frequency = :weekly
      type.fuel_type = :electricity
      type.sub_category = :electricity_use
      type.title = 'Alert Electricity Usage During Current Holiday with Community Use'
      type.source = :analytics
      type.has_ratings = true
      type.benchmark = true
      type.advice_page = AdvicePage.find_by!(key: :electricity_out_of_hours)
      type.link_to = 'analysis_page'
      type.link_to_section = 'holiday-usage'
      type.enabled = false
    end

    # AlertType.find_or_create_by!(class_name: 'AlertGasHeatingHotWaterOnDuringHoliday') do |type|
    #   type.frequency = :weekly
    #   type.fuel_type = :gas
    #   type.sub_category = :heating
    #   type.title = "Alert Gas Heating/Hot Water On during holidays"
    #   type.source = :analytics
    #   type.has_ratings = true
    #   type.benchmark = true
    # end

    # AlertType.find_or_create_by!(class_name: 'AlertStorageHeaterHeatingOnDuringHoliday') do |type|
    #   type.frequency = :weekly
    #   type.fuel_type = :storage_heater
    #   type.sub_category = :storage_heaters
    #   type.title = "Alert Storage Heater On during holidays"
    #   type.source = :analytics
    #   type.has_ratings = true
    #   type.benchmark = true
    # end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end

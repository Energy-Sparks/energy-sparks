namespace :after_party do
  desc 'Deployment task: update_activity_types_show_on_charts'
  task update_activity_types_show_on_charts: :environment do
    puts "Running deploy task 'update_activity_types_show_on_charts'"

    # Set all activities in the "Explorer" category to not be shown on charts
    # as these are mostly educational activities, so unlikely to have direct impacts
    # on energy usage.
    ActivityCategory.find_by(name: 'Explorer').activity_types.update_all(show_on_charts: false)

    # Set all activities in the "Analyst" category to not be shown on charts
    # as, again, these are learning activities.
    ActivityCategory.find_by(name: 'Analyst').activity_types.update_all(show_on_charts: false)

    ActivityType.where("name ILIKE '%electricity%' OR name ILIKE '%electrical%' OR name ILIKE '%lights%' OR name ILIKE '%lighting%' OR name ILIKE '%baseload%'").each do |activity_type|
      activity_type.fuel_type |= ['electricity']
      activity_type.save!
    end

    ActivityType.where("name ILIKE '%heating%' OR name ILIKE '%hot water%' OR name ILIKE '%gas%' OR name ILIKE '%thermostat%' OR name ILIKE '%temperature%' OR name ILIKE '%insulation%'").each do |activity_type|
      activity_type.fuel_type |= ['gas']
      activity_type.save!
    end

    ActivityType.where("name ILIKE '%solar%'").each do |activity_type|
      activity_type.fuel_type |= ['solar']
      activity_type.save!
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end

namespace :alerts do
  desc 'Run alert subscription events job'
  task create_alert_subscription_events_weekly: [:environment] do
    puts Time.zone.now
    schools = School.active
    schools.each do |school|
      puts "Running WEEKLY alert subscription events for #{school.name}"
      Alerts::GenerateSubscriptionEvents.new(school).perform(frequency: [:weekly])
    end
    puts Time.zone.now
  end

  task create_alert_subscription_events_termly: [:environment] do
    puts Time.zone.now
    schools = School.active
    schools.each do |school|
      if school.holiday_approaching?
        puts "Running TERMLY, BEFORE_EACH_HOLIDAY alert subscription events for #{school.name}"
        Alerts::GenerateSubscriptionEvents.new(school).perform(frequency: [:before_each_holiday, :termly])
      end
    end
    puts Time.zone.now
  end
end

namespace :alerts do
  desc 'Run alert subscription events job'
  task create_alert_subscription_events_weekly: [:environment] do
    puts Time.zone.now
    schools = School.active
    schools.each do |school|
      puts "Running WEEKLY alert subscription events for #{school.name}"
      school.alerts.weekly.latest.each do |alert|
        Alerts::GenerateSubscriptionEvents.new(school, alert).perform
      end
    end
    puts Time.zone.now
  end

  task create_alert_subscription_events_termly: [:environment] do
    puts Time.zone.now
    schools = School.active
    schools.each do |school|
      if school.holiday_approaching?
        puts "Running TERMLY alert subscription events for #{school.name}"
        school.alerts.termly.latest.each do |alert|
          Alerts::GenerateSubscriptionEvents.new(school, alert).perform
        end
      end
    end
    puts Time.zone.now
  end
end

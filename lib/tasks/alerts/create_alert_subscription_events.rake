namespace :alerts do
  desc 'Run alert subscription events job'
  task create_alert_subscription_events: [:environment] do
    puts Time.zone.now
    schools = School.active
    schools.each do |school|
      puts "Running alert subscription events for #{school.name}"
      Alerts::GenerateSubscriptionEvents.new(school).perform
    end
    puts Time.zone.now
  end
end

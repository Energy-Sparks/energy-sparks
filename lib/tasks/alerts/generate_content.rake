namespace :alerts do
  desc 'Run alert content job'
  task generate_content: [:environment] do
    puts Time.zone.now
    schools = School.process_data.with_config

    schools.each do |school|
      if Time.zone.today.wednesday?
        subscription_frequency = if school.holiday_approaching?
                                   [:weekly, :termly, :before_each_holiday]
                                 else
                                   [:weekly]
                                 end
        puts "Running alert content generation for #{school.name}, including #{subscription_frequency.to_sentence} subscriptions"
        Alerts::GenerateContent.new(school).perform(subscription_frequency: subscription_frequency)
      else
        puts "Running alert content generation for #{school.name}, without subscriptions"
        Alerts::GenerateContent.new(school).perform(subscription_frequency: [])
      end
    end

    puts Time.zone.now
  end
end

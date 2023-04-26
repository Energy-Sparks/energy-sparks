namespace :alerts do
  desc 'Run alert subscription job'
  task generate_subscriptions: [:environment] do
    puts "#{DateTime.now.utc} Generate subscriptions start"
    schools = School.data_enabled.process_data.visible.with_config

    schools.each do |school|
      puts "Running alert subscription generation for #{school.name}, including #{school.subscription_frequency.to_sentence} subscriptions"
      GenerateSubscriptionsJob.perform_later(school_id: school.id)
    end

    puts "#{DateTime.now.utc} Generate subscriptions end"
  end
end

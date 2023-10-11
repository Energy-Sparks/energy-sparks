namespace :recent_activities do
  desc 'Send weekly email with recent activities and interventions'
  task send_email: :environment do
    puts "#{DateTime.now.utc} Recent activity emailer start"
    if ENV['ENVIRONMENT_IDENTIFIER'] == 'production'
      @activities = Activity.recorded_in_last_week
      @observations = Observation.intervention.recorded_in_last_week
      if @activities.any? || @observations.any?
        RecentActivitiesMailer.with(activity_ids: @activities.map(&:id), observation_ids: @observations.map(&:id)).email.deliver_now
      else
        puts 'No activities or interventions recorded in the last week'
      end
    end
    puts "#{DateTime.now.utc} Recent activity emailer end"
  end
end

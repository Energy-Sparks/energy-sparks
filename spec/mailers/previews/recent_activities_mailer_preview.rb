class RecentActivitiesMailerPreview < ActionMailer::Preview
  def email
    activities = Activity.last(5)
    observations = Observation.intervention.last(5)
    RecentActivitiesMailer.with(activity_ids: activities.map(&:id), observation_ids: observations.map(&:id)).email
  end
end

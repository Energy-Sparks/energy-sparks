class RecentActivitiesMailer < ApplicationMailer
  helper :application

  def email
    @activities = Activity.find(params[:activity_ids])
    @observations = Observation.find(params[:observation_ids])
    make_bootstrap_mail(to: 'operations@energysparks.uk', subject: 'Recently recorded activities')
  end
end

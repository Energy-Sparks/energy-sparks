class Pupils::SchoolsController < SchoolsController
  def show
    @latest_alerts_sample = @school.alerts.usable.latest.sample(2)
  end
end

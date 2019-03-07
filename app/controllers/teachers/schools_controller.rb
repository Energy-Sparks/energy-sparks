class Teachers::SchoolsController < SchoolsController
  # GET /schools/1
  def show
    redirect_to enrol_path unless @school.active? || (current_user && current_user.manages_school?(@school.id))
    @activities = @school.activities.order("happened_on DESC")
    @latest_alerts_sample = @school.alerts.usable.latest.sample
  end
end

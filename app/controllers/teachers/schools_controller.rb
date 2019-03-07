class Teachers::SchoolsController < SchoolsController
  include SchoolAggregation
  # GET /schools/1
  def show
    redirect_to enrol_path unless @school.active? || (current_user && current_user.manages_school?(@school.id))
    @activities = @school.activities.order("happened_on DESC")
    @latest_alerts_sample = @school.alerts.usable.latest.sample

    @charts = [:electricity_by_day_of_week, :gas_by_day_of_week]
    @number_of_charts = @charts.size

    # Get this loaded and warm the cache before starting the chart rendering
    aggregate_school(@school)
  end
end

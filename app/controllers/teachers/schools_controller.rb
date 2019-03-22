class Teachers::SchoolsController < SchoolsController
  include ActivityTypeFilterable
  # GET /schools/slug-name
  def show
    redirect_to enrol_path unless @school.active? || (current_user && current_user.manages_school?(@school.id))
    @activities_count = @school.activities.count
    @find_out_more_alert = @school.latest_find_out_mores.sample
    if @find_out_more_alert
      @find_out_more_alert_content = TemplateInterpolation.new(@find_out_more_alert.content_version).interpolate(
        :dashboard_title,
        with: @find_out_more_alert.alert.template_variables
      )
      @find_out_more_alert_activity_types = @find_out_more_alert.alert.alert_type.activity_types.limit(3)
    end

    @charts = [:teachers_landing_page_electricity, :teachers_landing_page_gas]

    @first = @school.activities.empty?
    @completed_activity_count = @school.activities.count
    @suggestions = NextActivitySuggesterWithFilter.new(@school, activity_type_filter).suggest
  end
end

module Pupils
  class SchoolsController < ApplicationController
    include ActionView::Helpers::NumberHelper
    include ActivityTypeFilterable

    load_and_authorize_resource
    skip_before_action :authenticate_user!
    before_action :redirect_if_inactive

    def show
      @dashboard_alerts = @school.latest_dashboard_alerts.pupil.sample(2).map do |dashboard_alert|
        TemplateInterpolation.new(
          dashboard_alert.content_version,
          with_objects: {
            find_out_more: dashboard_alert.find_out_more,
            alert: dashboard_alert.alert
          },
          proxy: [:colour]
        ).interpolate(
          :pupil_dashboard_title,
          with: dashboard_alert.alert.template_variables
        )
      end
      activity_setup(@school)
      equivalence_setup(@school)

      @scoreboard = @school.scoreboard
      if @scoreboard
        @podium = Podium.create(school: @school, scoreboard: @scoreboard)
      end
      @observations = @school.observations
    end

  private

    def redirect_if_inactive
      redirect_to teachers_school_path(@school), notice: 'Pupil dashboard unavailable: School is not active' unless @school.active?
    end

    def activity_setup(school)
      @activities_count = school.activities.count
      @first = school.activities.empty?
      @suggestion = NextActivitySuggesterWithFilter.new(school, activity_type_filter).suggest.first
    end

    def equivalence_setup(school)
      @equivalence = school.equivalences.sample
      if @equivalence
        @equivalence_content = TemplateInterpolation.new(
          @equivalence.content_version
        ).interpolate(
          :equivalence,
          with: @equivalence.formatted_variables
        )
      end
    end
  end
end

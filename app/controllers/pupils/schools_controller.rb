module Pupils
  class SchoolsController < ApplicationController
    include ActionView::Helpers::NumberHelper
    include ActivityTypeFilterable

    load_and_authorize_resource

    def show
      authorize! :show_pupils_dash, @school
      @dashboard_alerts = @school.latest_dashboard_alerts.pupil_dashboard.sample(2).map do |dashboard_alert|
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

      @temperature_observations = @school.observations.temperature
    end

  private

    def activity_setup(school)
      @activities_count = school.activities.count
      @first = school.activities.empty?
      @suggestion = NextActivitySuggesterWithFilter.new(school, activity_type_filter).suggest_from_activity_history.first
    end

    def equivalence_setup(school)
      @equivalences = school.equivalences.relevant
      @equivalences_content = @equivalences.includes(:content_version).map do |equivalence|
        TemplateInterpolation.new(
          equivalence.content_version,
          with_objects: { equivalence_type: equivalence.content_version.equivalence_type },
        ).interpolate(
          :equivalence,
          with: equivalence.formatted_variables
        )
      end
    end
  end
end

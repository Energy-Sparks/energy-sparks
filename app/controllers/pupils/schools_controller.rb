module Pupils
  class SchoolsController < BaseController
    include ActionView::Helpers::NumberHelper
    include ActivityTypeFilterable
    include DashboardAlerts

    def show
      authorize! :show_pupils_dash, @school
      @dashboard_alerts = setup_alerts(@school.latest_dashboard_alerts.pupil_dashboard, :pupil_dashboard_title, limit: 2)
      activity_setup(@school)
      equivalence_setup(@school)

      @temperature_observations = @school.observations.temperature
      @show_temperature_observations = show_temperature_observations?
    end

  private

    def activity_setup(school)
      @activities_count = school.activities.count
      @first = school.activities.empty?
      activity_suggester = NextActivitySuggesterWithFilter.new(school, activity_type_filter)
      @suggestion = (activity_suggester.suggest_from_programmes + activity_suggester.suggest_from_activity_history + activity_suggester.suggest_from_find_out_mores).first
    end

    def equivalence_setup(school)
      @equivalences = Equivalences::RelevantAndTimely.new(school).equivalences

      @equivalences_content = @equivalences.map do |equivalence|
        TemplateInterpolation.new(
          equivalence.content_version,
          with_objects: { equivalence_type: equivalence.content_version.equivalence_type },
        ).interpolate(
          :equivalence,
          with: equivalence.formatted_variables
        )
      end
    end

    def show_temperature_observations?
      site_settings.temperature_recording_month_numbers.include?(Time.zone.today.month)
    end
  end
end

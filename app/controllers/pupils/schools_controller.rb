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
      @scoreboard = @school.scoreboard
      if @scoreboard
        @surrounding_schools = @scoreboard.surrounding_schools(@school)
      end

      @message = message_for_speech_bubble(@school)
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

    def message_for_speech_bubble(school)
      if school.has_enough_readings_for_meter_types?(:electricity)
        average_usage = MeterCard.calulate_average_usage(school: school, supply: :electricity, window: 7)
        electricity_message = random_equivalence_text(average_usage, :electricity) if average_usage
      end

      if school.has_enough_readings_for_meter_types?(:gas)
        average_usage = MeterCard.calulate_average_usage(school: school, supply: :gas, window: 7)
        gas_message = random_equivalence_text(average_usage, :gas) if average_usage
      end

      if electricity_message && gas_message
        [electricity_message, gas_message].sample
      elsif electricity_message
        electricity_message
      else
        gas_message
      end
    end

    def random_equivalence_text(kwh, fuel_type)
      equiv_type, conversion_type = EnergyEquivalences.random_equivalence_type_and_via_type
      _val, equivalence = EnergyEquivalences.convert(kwh, :kwh, fuel_type, equiv_type, equiv_type, conversion_type)

      "Your school uses an average of #{number_with_delimiter(kwh.round)} kWh of #{fuel_type} a day. #{equivalence}"
    end
  end
end

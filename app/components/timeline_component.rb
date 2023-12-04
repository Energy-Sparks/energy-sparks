# frozen_string_literal: true

class TimelineComponent < ViewComponent::Base
  include ApplicationHelper

  attr_reader :observations, :show_actions

  def initialize(observations:, show_actions: false)
    @observations = observations
    @show_actions = show_actions
  end

  class Observation < ViewComponent::Base
    attr_reader :observation, :show_actions

    def initialize(observation:, show_actions: false)
      @observation = observation
      @show_actions = show_actions
    end

    def call
      render("TimelineComponent::#{observation.observation_type.camelize}Component".constantize.new(observation: observation, show_actions: show_actions))
    end
  end

  class ObservationBaseComponent < ViewComponent::Base
    attr_reader :observation, :show_actions

    def initialize(observation:, show_actions: false)
      @observation = observation
      @show_actions = show_actions
    end

    # def message
    #  raise "Implement me!"
    # end
  end

  class ActivityComponent < ObservationBaseComponent
  end

  class AuditComponent < ObservationBaseComponent
  end

  class AuditActivitiesCompleteComponent < ObservationBaseComponent
  end

  class InterventionComponent < ObservationBaseComponent
  end

  class ObservableComponent < ObservationBaseComponent
  end

  class ProgrammeComponent < ObservationBaseComponent
  end

  class SchoolTargetComponent < ObservationBaseComponent
  end

  class TemperatureComponent < ObservationBaseComponent
  end

  class TransportSurveyComponent < ObservationBaseComponent
    attr_reader :observation

    def initialize(observation)
      @observation = observation
    end

    def icon
    end

    def message
      I18n.t('schools.observations.timeline.transport_survey.message', count: observation.observable.responses.count)
    end

    def compact_message
    end
  end

  ####
end

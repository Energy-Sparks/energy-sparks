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
      render("TimelineComponent::#{observation.observation_type.camelize}".constantize.new(observation: observation, show_actions: show_actions))
    end
  end

  class ObservationBase < ViewComponent::Base
    attr_reader :observation, :show_actions

    delegate :fa_icon, :nice_dates, :can?, to: :helpers

    def initialize(observation:, show_actions: false)
      @observation = observation
      @show_actions = show_actions
    end

    # def message
    #  raise "Implement me!"
    # end
  end

  class Activity < ObservationBase
  end

  class Audit < ObservationBase
  end

  class AuditActivitiesCompleted < ObservationBase
  end

  class Intervention < ObservationBase
  end

  class Observable < ObservationBase
  end

  class Programme < ObservationBase
  end

  class SchoolTarget < ObservationBase
  end

  class Temperature < ObservationBase
  end

  class TransportSurvey < ObservationBase
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

# frozen_string_literal: true

class TimelineComponent < ViewComponent::Base
  include ApplicationHelper

  attr_reader :observations, :show_actions, :id

  def initialize(observations:, show_actions: false, classes: nil, id: nil)
    @observations = observations
    @show_actions = show_actions
    @classes = classes
    @id = id
  end

  def classes
    " #{@classes}"
  end

  def render?
    observations.any?
  end

  class Observation < ViewComponent::Base
    attr_reader :observation, :show_actions

    def initialize(observation:, show_actions: false)
      @observation = observation
      @show_actions = show_actions
    end

    def call
      if observation.observable
        render("TimelineComponent::#{observation.observable_type}".constantize.new(observation: observation, show_actions: show_actions))
      else
        render("TimelineComponent::#{observation.observation_type.camelize}".constantize.new(observation: observation, show_actions: show_actions))
      end
    end
  end

  class ObservationBase < ViewComponent::Base
    attr_reader :observation, :show_actions

    delegate :fa_icon, :nice_dates, :can?, to: :helpers

    def initialize(observation:, show_actions: false)
      @observation = observation
      @show_actions = show_actions
    end

    def icon
      'square-check' # please override subclasses
    end

    def observable
      observation.observable
    end

    def timeline_text
    end
  end

  class Activity < ObservationBase
  end

  class Audit < ObservationBase
  end

  class AuditActivitiesCompleted < ObservationBase
  end

  class Intervention < ObservationBase
  end

  class Programme < ObservationBase
  end

  class SchoolTarget < ObservationBase
  end

  class Temperature < ObservationBase
  end

  class TransportSurvey < ObservationBase
    def icon
      'car'
    end

    def message
      I18n.t('components.timeline.transport_survey.message', count: observation.observable.responses.count)
    end
  end
end

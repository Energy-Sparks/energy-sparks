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
    attr_reader :observation, :show_actions, :compact

    def initialize(observation:, show_actions: false, compact: false)
      @observation = observation
      @show_actions = show_actions
      @compact = compact
    end

    def klass
      observation.observable_type || observation.observation_type.camelize
    end

    def component
      "TimelineComponent::#{klass}".constantize.new(observation: observation, show_actions: show_actions, compact: compact)
    end

    def call
      render(component)
    end
  end

  class ObservationBase < ViewComponent::Base
    attr_reader :observation, :show_actions, :compact

    delegate :fa_icon, :nice_dates, :can?, to: :helpers

    def initialize(observation:, show_actions: false, compact: false)
      @observation = observation
      @show_actions = show_actions
      @compact = compact
    end

    def icon
      size = compact ? 1 : 2
      fa_icon("#{icon_name} fa-#{size}x")
    end

    def show_path
      polymorphic_path([observable.school, observable])
    end

    def edit_path
      edit_polymorphic_path([observable.school, observable])
    end

    def delete_path
      polymorphic_path([observable.school, observable])
    end

    def icon_name
      'clipboard-check'
    end

    def observable
      observation.observable
    end

    def school
      observation.school
    end

    def can_show?
      true
    end

    def can_edit?
      true
    end

    def show_actions?
      show_actions && can?(:manage, observable)
    end

    def target
    end

    def message
      I18n.t("components.timeline.#{self.class.name.demodulize.underscore}.message")
    end

    def compact_path
      show_path
    end
  end

  class Activity < ObservationBase
    # icon_name - clipboard-check
    def observable
      observation.activity
    end

    def target
      observation.activity.display_name
    end

    def compact_path
      activity_type_path(observation.activity.activity_type)
    end
  end

  class Audit < ObservationBase
    # icon_name - clipboard-check
    def observable
      observation.audit
    end

    def target
      observation.audit.title
    end

    def can_show?
      can?(:show, observation.audit) && observation.audit.published?
    end
  end

  class AuditActivitiesCompleted < ObservationBase
    def observable
      observation.audit
    end

    def target
      observation.audit.title
    end

    def show_actions?
      false
    end
  end

  class Intervention < ObservationBase
    def icon_name
      observation.intervention_type.intervention_type_group.icon
    end

    def observable
      observation.intervention_type
    end

    def show_path
      school_intervention_path(observation.school, observation)
    end

    def edit_path
      edit_school_intervention_path(observation.school, observation)
    end

    def delete_path
      school_intervention_path(observation.school, observation)
    end

    def target
      observation.intervention_type.name
    end

    def compact_path
      intervention_type_path(observable)
    end
  end

  class Programme < ObservationBase
    # icon_name - clipboard-check
    def observable
      observation.programme
    end

    def show_path
      programme_type_path(observation.programme.programme_type)
    end

    def target
      observation.programme.programme_type.title
    end

    def show_actions?
      false
    end

    def compact_path
      show_path
    end
  end

  class SchoolTarget < ObservationBase
    def icon_name
      'tachometer-alt'
    end

    def observable
      observation.school_target
    end

    def can_edit?
      !observation.school_target.expired?
    end
  end

  class Temperature < ObservationBase
    def icon_name
      'temperature-high'
    end

    def target
      observation.locations.map(&:name).uniq.to_sentence
    end

    def show_path
      school_temperature_observations_path(observation.school)
    end

    def can_edit?
      false
    end

    def delete_path
      school_temperature_observation_path(observation.school, observation)
    end

    def show_actions?
      show_actions && can?(:delete, observation)
    end
  end

  class TransportSurvey < ObservationBase
    def icon_name
      'car'
    end

    def message
      I18n.t('components.timeline.transport_survey.message', count: observation.observable.responses.count)
    end
  end
end

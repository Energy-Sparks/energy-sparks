# frozen_string_literal: true

module Tasks
  class Header < ApplicationComponent # rubocop:disable ViewComponent/ComponentSuffix
    attr_reader :task, :recording

    def initialize(task: nil, recording: nil, **_kwargs)
      super
      @recording = recording
      @task = task || recording.task
    end

    def recording?
      recording.present?
    end

    def persisted_recording?
      recording? && recording.persisted?
    end

    def exceeded_maximum?
      recording.task.exceeded_maximum_in_year?(recording.school)
    end

    def activity_type?
      task.is_a?(ActivityType)
    end

    private

    def recording_key
      @recording_key ||= activity_type? ? 'activities' : 'interventions'
    end
  end
end

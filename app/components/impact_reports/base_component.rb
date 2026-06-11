# frozen_string_literal: true

module ImpactReports
  class BaseComponent < ApplicationComponent # rubocop:disable ViewComponent/MissingPreview
    delegate :impact_t, to: :helpers

    def initialize(run: nil, school_group: nil, **)
      super(**)
      @run = run || school_group&.impact_report_runs&.latest
      @school_group = school_group || run&.school_group
      @config = @school_group.impact_report_configuration
    end
  end
end

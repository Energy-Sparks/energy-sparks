# frozen_string_literal: true

module ImpactReports
  class BaseComponent < ApplicationComponent # rubocop:disable ViewComponent/MissingPreview
    delegate :impact_t, :format_unit, to: :helpers

    attr_reader :run

    delegate(*ImpactReport::Metric.metric_categories.keys, to: :run, allow_nil: true)

    def initialize(run: nil, impact_report: nil, school_group: nil, **)
      super(**)
      @impact_report = impact_report # evenually shouldn't need this
      @run = run
      @school_group = school_group || run&.school_group || impact_report&.school_group
      @config = @school_group.impact_report_configuration
    end
  end
end

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

    private

    def display?(metric)
      displayable.include?(metric)
    end

    def displayable
      raise NotImplementedError, "#{self.class} must implement #displayable"
    end

    def render?
      displayable.any?
    end

    def cols
      count = displayable.count

      return count if count <= 4
      return 3 if (count % 3).zero?

      # Prefer 4 columns, otherwise 3, but avoid layouts that leave exactly one item stranded on the last row
      [4, 3].reject { |cols| (count % cols) == 1 }.first || 4
    end

    def raise_unless_run
      raise ArgumentError, 'run parameter is required' if run.nil?
    end
  end
end

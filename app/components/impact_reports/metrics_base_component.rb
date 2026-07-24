# frozen_string_literal: true

module ImpactReports
  class MetricsBaseComponent < ApplicationComponent # rubocop:disable ViewComponent/MissingPreview
    delegate :impact_t, :format_unit, to: :helpers

    attr_reader :run

    delegate(*ImpactReport::Metric.metric_categories.keys, to: :run, allow_nil: true)

    def initialize(run:, **)
      super(**)
      @run = run
      @school_group = run.school_group
    end

    def displayable? # rubocop:disable ViewComponent/PreferPrivateMethods
      displayable.any?
    end

    private

    def display?(metric)
      displayable.include?(metric)
    end

    def displayable
      raise NotImplementedError, "#{self.class} must implement #displayable"
    end

    def render?
      displayable?
    end

    def cols
      count = displayable.count

      return count if count <= 4
      return 3 if (count % 3).zero?

      # Prefer 4 columns, otherwise 3, but avoid layouts that leave exactly one item stranded on the last row
      [4, 3].reject { |cols| (count % cols) == 1 }.first || 4
    end
  end
end

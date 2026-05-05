# frozen_string_literal: true

module ImpactReports
  class BaseComponent < ApplicationComponent # rubocop:disable ViewComponent/MissingPreview
    delegate :impact_t, :format_unit, to: :helpers

    def initialize(impact_report: nil, school_group: nil, **)
      super(**)
      @impact_report = impact_report if impact_report
      @school_group = school_group || @impact_report.school_group
      @config = @school_group.impact_report_configuration
    end
  end
end

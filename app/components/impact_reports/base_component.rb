# frozen_string_literal: true

module ImpactReports
  class BaseComponent < ApplicationComponent # rubocop:disable ViewComponent/MissingPreview
    delegate :impact_t, to: :helpers

    def initialize(school_group:, **)
      super(**)
      @school_group = school_group
      @config = @school_group.impact_report_configuration
    end
  end
end

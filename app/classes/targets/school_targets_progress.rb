module Targets
  class SchoolTargetsProgress
    attr_reader :school, :targets_enabled, :enough_data, :progress_summary

    def initialize(school:, targets_enabled:, enough_data: nil, progress_summary: nil)
      @school = school
      @targets_enabled = targets_enabled
      @enough_data = enough_data
      @progress_summary = progress_summary
    end

    def school_target
      progress_summary.present? ? progress_summary.school_target : nil
    end

    def school_target?
      school_target.present?
    end
  end
end

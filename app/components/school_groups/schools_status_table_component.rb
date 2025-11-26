# frozen_string_literal: true

module SchoolGroups
  class SchoolsStatusTableComponent < ApplicationComponent
    attr_reader :records

    def initialize(school_group:, schools: [], onboardings: [], **_kwargs)
      super
      @school_group = school_group
      @schools = schools # should we enforce active here?
      @onboardings = onboardings # should we enforce incomplete here?
      @records = merge_schools_and_onboardings
    end

    def fuel_types
      @school_group.fuel_types
    end

    def status(record)
      return :onboarding if record.is_a?(SchoolOnboarding)
      if record.data_visible?
        :data_visible
      elsif record.visible?
        :visible
      else
        :onboarding
      end
    end

    def merge_schools_and_onboardings
      school_ids = @schools.map(&:id).to_set

      @schools + @onboardings.reject { |o| school_ids.include?(o.school_id) }
    end

    def render?
      @records.any?
    end
  end
end

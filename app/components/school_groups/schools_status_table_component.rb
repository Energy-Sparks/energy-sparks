# frozen_string_literal: true

module SchoolGroups
  class SchoolsStatusTableComponent < ApplicationComponent
    attr_reader :records

    def initialize(school_group:, records:, **_kwargs)
      super
      @school_group = school_group
      @records = records
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

    def render?
      @records.any?
    end
  end
end

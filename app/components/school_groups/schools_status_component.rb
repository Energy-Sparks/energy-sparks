# frozen_string_literal: true

module SchoolGroups
  class SchoolsStatusComponent < ApplicationComponent
    attr_reader :records

    def initialize(school_group:, schools:, onboardings:, **_kwargs)
      super
      @school_group = school_group
      @schools = schools.active # should already be active, but just to be sure
      @onboardings = onboardings.incomplete # should already be incomplete by now
      @records = merge_schools_and_onboardings
    end

    def fuel_types
      # @school_group.fuel_types(@schools)
      # Display all possible fuel types for consistency
      Schools::FuelConfiguration.fuel_types
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

      # add onboardings that do not have a corresponding school already
      @schools + @onboardings.reject { |o| school_ids.include?(o.school_id) }
    end
  end
end

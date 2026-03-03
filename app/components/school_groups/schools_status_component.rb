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

    # Display all possible fuel types
    # But removing storage_heaters if school group does not have it
    def fuel_types
      @fuel_types ||= begin
        fuel_types = Schools::FuelConfiguration.fuel_types.dup
        fuel_types -= [:storage_heaters] unless @school_group.fuel_types.include?(:storage_heaters)
        fuel_types
      end
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

    def fuel_sort(record, fuel_type)
      return 3 if status(record) != :data_visible
      record.fuel_type?(fuel_type) ? 1 : 2
    end

    def merge_schools_and_onboardings
      school_ids = @schools.map(&:id).to_set

      # add onboardings that do not have a corresponding school already
      @schools + @onboardings.reject { |o| school_ids.include?(o.school_id) }
    end
  end
end

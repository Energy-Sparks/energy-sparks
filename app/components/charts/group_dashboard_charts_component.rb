module Charts
  class GroupDashboardChartsComponent < ApplicationComponent
    attr_reader :school_group, :reports

    renders_one :title
    renders_one :intro
    renders_one :extra_note

    def initialize(school_group:,
                   comparisons: [:annual_electricity_costs_per_pupil, :annual_heating_costs_per_floor_area],
                   **_kwargs)
      super
      @school_group = school_group
      @reports = comparisons.filter_map { |k| Comparison::Report.find_by_key(k) }
    end

    def render?
      reports&.any? && school_group.assigned_schools.data_visible.count > 1
    end
  end
end

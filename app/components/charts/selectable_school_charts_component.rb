module Charts
  class SelectableSchoolChartsComponent < ApplicationComponent
    attr_reader :schools, :charts

    def initialize(schools:, charts:, fuel_types:,
                   defaults: { school: nil, chart_type: nil, fuel_type: nil },
                   **_kwargs)
      super
      @schools = schools
      @charts = charts
      @fuel_types = fuel_types
      @defaults = defaults
      add_classes('row')
    end

    def render?
      @fuel_types.any? && @schools.any? && @charts.any?
    end

    private

    def default_configuration
      helpers.create_chart_config(default_school, default_chart_type)
    end

    def default_chart_title
      default_chart[:title] || default_chart[:label]
    end

    def default_chart_subtitle
      default_chart[:subtitle]&.gsub('{{name}}', default_school.name) || ''
    end

    def default_link
      polymorphic_path([default_school, :advice, default_chart[:advice_page]])
    end

    def default_chart
      @charts[default_fuel_type][default_chart_type]
    end

    def default_chart_type
      @charts[default_fuel_type].key?(@defaults[:chart_type]) ? @defaults[:chart_type] : @charts[default_fuel_type].keys.first
    end

    def default_fuel_type
      @fuel_types.include?(@defaults[:fuel_type]) ? @defaults[:fuel_type] : @fuel_types.first
    end

    def default_school
      @schools.include?(@defaults[:school]) ? @defaults[:school] : @schools.first
    end

    def enable_school?(school)
      school.configuration.fuel_configuration.fuel_types.include?(default_fuel_type)
    end

    def fuel_types_for_school(school)
      school.configuration.fuel_configuration.fuel_type_tokens
    end
  end
end

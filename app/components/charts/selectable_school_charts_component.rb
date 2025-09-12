module Charts
  # A list of schools that can be seen by user
  # A list of possible charts
  #
  # Filtering if fuel_type doesn't apply?, e.g. no storage heater charts
  # Grouping based on categories of school, e.g. High baseload
  # How to supply title/subtitle translation keys and parameters
  class SelectableSchoolChartsComponent < ApplicationComponent
    attr_reader :schools, :charts

    def initialize(schools:, charts:, fuel_types:, **_kwargs)
      super
      @schools = schools
      @charts = charts
      @fuel_types = fuel_types
    end

    private

    def default_configuration
      helpers.create_chart_config(default_school, default_chart)
    end

    def default_chart
      @charts[@fuel_types.first].keys.first
    end

    def default_school
      @schools.first
    end

    def fuel_types_for_school(school)
      school.configuration.fuel_configuration.fuel_type_tokens
    end
  end
end

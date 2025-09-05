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
  end
end

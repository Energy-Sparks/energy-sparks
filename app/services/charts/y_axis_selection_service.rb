module Charts
  class YAxisSelectionService
    def initialize(school, chart_name)
      @school = school
      @chart_name = chart_name
    end

    #all potential options
    def self.possible_y1_axis_choices
      %i[kwh £ co2]
    end

    #actual options for this chart
    def y1_axis_choices(existing_config = nil)
      config = existing_config || chart_config
      ChartYAxisManipulation.new.y1_axis_choices(config)
    end

    #select the appropriate default y-axis for this school
    #may be nil if no preference applies/should be set
    def select_y_axis
      return nil unless @school.prefer_climate_reporting?
      choices = y1_axis_choices
      return nil if choices.nil?
      return :co2 if choices.include?(:co2)
      return :kwh if choices.include?(:kwh)
      return nil
    end

    private

    def chart_config
      @chart_config ||= ChartManager.build_chart_config(ChartManager::STANDARD_CHART_CONFIGURATION[@chart_name])
    end
  end
end

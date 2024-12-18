module Charts
  class YAxisSelectionService
    def initialize(school, chart_name)
      @school = school
      @chart_name = chart_name
    end

    # all potential options
    def self.possible_y1_axis_choices
      %i[kwh £ co2]
    end

    # actual options for this chart
    def y1_axis_choices(existing_config = nil)
      config = existing_config || chart_config
      ChartYAxisManipulation.new.y1_axis_choices(config)
    end

    # select the appropriate default y-axis for this school
    # may be nil if no preference applies/should be set
    def select_y_axis
      choices = y1_axis_choices
      return nil if choices.nil?
      case @school.chart_preference.to_sym
      when :default
        return nil
      when :carbon
        return :co2 if choices.include?(:co2)
      when :usage
        return :kwh if choices.include?(:kwh)
      when :cost
        return :£ if choices.include?(:£)
      end
      nil
    end

    private

    def chart_config
      @chart_config ||= ChartManager.build_chart_config(ChartManager::STANDARD_CHART_CONFIGURATION.fetch(@chart_name))
    end
  end
end

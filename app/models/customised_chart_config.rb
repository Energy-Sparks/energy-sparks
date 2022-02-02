class CustomisedChartConfig
  def initialize(original_config)
    @original_config = original_config
  end

  def customise(overrides)
    new_config = {}

    customise_y_axis(new_config, overrides)
    customise_meter_definition(new_config, overrides)
    customise_series_breakdown(new_config, overrides)
    customise_timescale(new_config, overrides)

    @original_config.merge(new_config)
  end

  private

  def customise_y_axis(new_config, overrides)
    if overrides[:y_axis_units]
      overrides[:y_axis_units] = :£ if overrides[:y_axis_units] == :gb_pounds
      valid_choices = ChartYAxisManipulation.new(nil).y1_axis_choices(@original_config)
      new_config[:yaxis_units] = overrides[:y_axis_units] if valid_choices && valid_choices.include?(overrides[:y_axis_units])
    end
  end

  def customise_meter_definition(new_config, overrides)
    if overrides[:mpan_mprn].present?
      new_config[:meter_definition] = overrides[:mpan_mprn].to_i
    end
  end

  def customise_series_breakdown(new_config, overrides)
    if overrides[:series_breakdown].present?
      new_config[:series_breakdown] = overrides[:series_breakdown].to_sym
    end
  end

  def customise_timescale(new_config, overrides)
    if overrides[:date_ranges].present?
      new_config[:timescale] = overrides[:date_ranges].map {|range| { daterange: range }}
    end
  end
end

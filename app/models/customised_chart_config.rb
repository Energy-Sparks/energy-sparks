#Based on an existing config, create a new modified chart config drawing on some "overrides"
#specified in a separate hash. The overrides are a slightly different version of the
#chart config that has different keys populated from url params. So there's an element of translation
#here for what the analytics is using.
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
      #not using service here as we're applying the users direct selection of axis
      valid_choices = ChartYAxisManipulation.new.y1_axis_choices(@original_config)
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

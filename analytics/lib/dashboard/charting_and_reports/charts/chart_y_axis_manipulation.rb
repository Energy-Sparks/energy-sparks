# Centrica
class ChartYAxisManipulation
  class CantChangeY1AxisException < StandardError; end
  class CantChangeY2AxisException < StandardError; end

  def y1_axis_choices(inherited_chart_config)
    full_y1_choices = %i[kwh £ co2]
    chart_axis_choices(inherited_chart_config, full_y1_choices, :yaxis_units, :restrict_y1_axis)
  end

  def change_y1_axis_config(inherited_chart_config, new_axis_units)
    choices = y1_axis_choices(inherited_chart_config)
    raise CantChangeY1AxisException, "Unable to change y1 axis to #{new_axis_units}" if choices.nil? ||  !choices.include?(new_axis_units)

    new_config = ChartManager.build_chart_config(inherited_chart_config)

    new_config.merge({yaxis_units: new_axis_units})
  end

  def y2_axis_choices(inherited_chart_config)
    full_y2_choices = %i[temperature degreedays irradiance gridcarbon gascarbon]
    chart_axis_choices(inherited_chart_config, full_y2_choices, :y2_axis, :restrict_y2_axis)
  end

  def change_y2_axis_config(inherited_chart_config, new_axis_units)
    choices = y2_axis_choices(inherited_chart_config)
    raise CantChangeY2AxisException, "Unable to change y2 axis to #{new_axis_units}"  if choices.nil? ||  !choices.include?(new_axis_units)

    new_config = ChartManager.build_chart_config(inherited_chart_config)

    new_config.merge({y2_axis: new_axis_units})
  end

  def chart_axis_choices(inherited_chart_config, choices, axis_key, restriction_key)
    chart_config = ChartManager.build_chart_config(inherited_chart_config)

    current_unit = chart_config[axis_key]

    if !chart_config[restriction_key].nil?
      chart_config[restriction_key] == [current_unit] ? nil : chart_config[restriction_key]
    elsif choices.include?(current_unit)
      return choices
    else
      nil
    end
  end
end

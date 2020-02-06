require 'dashboard'

class ChartData
  OPERATIONS = %i[move extend contract compare].freeze

  def initialize(aggregated_school, original_chart_type, chart_config, transformations: [], show_benchmark_figures: false)
    @aggregated_school = aggregated_school
    @original_chart_type = original_chart_type
    @chart_config_overrides = chart_config
    @transformations = transformations
    @show_benchmark_figures = show_benchmark_figures
  end

  def data
    chart_manager = ChartManager.new(@aggregated_school, @show_benchmark_figures)

    chart_config = customised_chart_config(chart_manager)

    transformed_chart_type, transformed_chart_config = apply_transformations(@transformations, @original_chart_type, chart_config, chart_manager)

    allowed_operations = check_operations(transformed_chart_config)
    drilldown_available = chart_manager.drilldown_available?(transformed_chart_config)
    parent_timescale_description = chart_manager.parent_chart_timescale_description(transformed_chart_config)

    values = ChartDataValues.new(
      chart_manager.run_chart(transformed_chart_config, transformed_chart_type),
      transformed_chart_type,
      transformations: @transformations,
      allowed_operations: allowed_operations,
      drilldown_available: drilldown_available,
      parent_timescale_description: parent_timescale_description
    ).process

    values
  end

  def has_chart_data?
    ! data.series_data.nil?
  rescue EnergySparksNotEnoughDataException, EnergySparksNoMeterDataAvailableForFuelType, EnergySparksMissingPeriodForSpecifiedPeriodChart
    false
  rescue => e
    Rails.logger.error "Chart generation failed unexpectedly for #{@original_chart_type} and #{@school.name} - #{e.message}"
    Rollbar.error(e, school_id: @school.id, school_name: @school.name, original_chart_type: @original_chart_type, chart_config_overrides: @chart_config_overrides, transformations: @transformations)
    false
  end

private

  def customised_chart_config(chart_manager)
    chart_config = chart_manager.get_chart_config(@original_chart_type)
    CustomisedChartConfig.new(chart_config).customise(@chart_config_overrides)
  end

  def apply_transformations(transformations, original_chart_type, custom_chart_config, chart_manager)
    transformations.inject([original_chart_type, custom_chart_config]) do |(chart_type, chart_config), (transformation_type, transformation_value)|
      case transformation_type
      when *OPERATIONS then [chart_type, apply_operation(transformation_type, transformation_value, chart_config)]
      when :drilldown then apply_drilldown(transformation_value, chart_type, chart_config, chart_manager)
      else chart_config
      end
    end
  end

  def apply_operation(operation_type, adjustment, chart_config)
    manipulator = ChartManagerTimescaleManipulation.factory(operation_type, chart_config, @aggregated_school)
    manipulator.adjust_timescale(adjustment)
  end

  def apply_drilldown(x_axis_range, chart_type, chart_config, chart_manager)
    original_chart_results = chart_manager.run_chart(chart_config, chart_type)
    drill_down_range = original_chart_results[:x_axis_ranges][x_axis_range]
    chart_manager.drilldown(chart_type, chart_config, nil, drill_down_range)
  end

  def check_operations(chart_config)
    allowed_operations = {}
    OPERATIONS.each do |operation_type|
      manipulator = ChartManagerTimescaleManipulation.factory(operation_type, chart_config, @aggregated_school)
      allowed_operations[operation_type] = if manipulator.chart_suitable_for_timescale_manipulation?
        {
          timescale_description: manipulator.timescale_description,
          directions: {
            forward: (manipulator.can_go_forward_in_time_one_period? rescue false), # remove rescue once manipulation for drilled down charts is fixed
            back: (manipulator.can_go_back_in_time_one_period? rescue false) # remove rescue once manipulation for drilled down charts is fixed
          }
        }
                                           else
        {
          timescale_description: 'period',
          directions: {
            forward: false,
            back: false
          }
        }
                                           end
    end
    allowed_operations
  end
end

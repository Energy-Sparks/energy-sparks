require 'dashboard'

class ChartData
  OPERATIONS = %i[move extend contract compare].freeze

  def initialize(school, aggregated_school, original_chart_type, chart_config, transformations: [], provide_advice: false, reraise_exception: false)
    @school = school
    @aggregated_school = aggregated_school
    @original_chart_type = original_chart_type
    @chart_config_overrides = chart_config
    @transformations = transformations
    @provide_advice = provide_advice
    @reraise_exception = reraise_exception
  end

  def data
    chart_manager = ChartManager.new(@aggregated_school)
    chart_config = customised_chart_config(chart_manager)

    transformed_chart_type, transformed_chart_config = apply_transformations(@transformations, @original_chart_type, chart_config, chart_manager)

    allowed_operations = check_operations(transformed_chart_config)
    drilldown_available = chart_manager.drilldown_available?(transformed_chart_config)

    parent_timescale_description = chart_manager.parent_chart_timescale_description(transformed_chart_config)
    parent_timescale_description = I18n.t("chart_data.timescale_description.#{parent_timescale_description}", default: nil) || parent_timescale_description


    run_chart = run_chart_for(chart_manager, transformed_chart_config, transformed_chart_type)

    values = ChartDataValues.new(
      run_chart,
      transformed_chart_type,
      transformations: @transformations,
      allowed_operations: allowed_operations,
      drilldown_available: drilldown_available,
      parent_timescale_description: parent_timescale_description,
      y1_axis_choices: Charts::YAxisSelectionService.new(@school, transformed_chart_type).y1_axis_choices(transformed_chart_config)
    ).process

    values
  end

  def run_chart_for(chart_manager, transformed_chart_config, transformed_chart_type)
    chart_manager.run_chart(
      transformed_chart_config,       # chart_config
      transformed_chart_type,         # chart_param
      true,                           # resolve_inheritance
      nil,                            # override_config
      @reraise_exception,             # reraise_exception
      provide_advice: @provide_advice # provide_advice
    )
  rescue => e
    if @reraise_exception
      Rollbar.error(
        e,
        school_name: @school.name,
        transformed_chart_config: transformed_chart_config,
        transformed_chart_type: transformed_chart_type,
        provide_advice: @provide_advice
      )
      Rails.logger.error "Chart run failed unexpectedly for #{transformed_chart_type} and #{@school.name} - #{e.message}"
    end
    nil
  end

  def has_chart_data?
    ! data.series_data.nil?
  rescue EnergySparksNotEnoughDataException, EnergySparksNoMeterDataAvailableForFuelType, EnergySparksMissingPeriodForSpecifiedPeriodChart
    false
  rescue => e
    Rails.logger.error "Chart generation failed unexpectedly for #{@original_chart_type} and #{@aggregated_school.name} - #{e.message}"
    Rollbar.error(e, school_name: @school.name, original_chart_type: @original_chart_type, chart_config_overrides: @chart_config_overrides, transformations: @transformations)
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
    original_chart_results = chart_manager.run_chart(chart_config, chart_type, provide_advice: @provide_advice)
    drill_down_range = original_chart_results[:x_axis_ranges][x_axis_range]
    chart_manager.drilldown(chart_type, chart_config, nil, drill_down_range)
  end

  def check_operations(chart_config)
    allowed_operations = {}
    OPERATIONS.each do |operation_type|
      manipulator = ChartManagerTimescaleManipulation.factory(operation_type, chart_config, @aggregated_school)
      allowed_operations[operation_type] = if manipulator.chart_suitable_for_timescale_manipulation?
        timescale_description = I18n.t("chart_data.timescale_description.#{manipulator.timescale_description.downcase}", default: nil) || manipulator.timescale_description
        {
          timescale_description: timescale_description,
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

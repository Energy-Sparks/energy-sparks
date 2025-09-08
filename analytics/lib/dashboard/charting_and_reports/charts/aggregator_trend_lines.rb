class AggregatorTrendlines < AggregatorBase
  def create
    create_trend_lines
  end

  private

  attr_reader :regression_parameters

  # - process trendlines post aggregation as potentially faster, if line
  #   is represented by fewer points
  # - only works for model_type breakdowns for the moment. and only for 'daily' bucketing
  # - ignore bucketed data count as probably doesn;t apply to scatter plots with trendlines for the moment
  def create_trend_lines
    calculate_regression_parameters_outside_model

    if Object.const_defined?('Rails')
      add_trendlines_for_rails_all_points
    elsif false && Object.const_defined?('Rails')
      add_trendlines_for_rails_2_points
    else
      analytics_excel_trendlines
    end
  end

  def analytics_excel_trendlines
    results.series_manager.trendlines.each do |trendline_series_name|
      model_type_for_trendline = Series::ManagerBase.series_name_for_trendline(trendline_series_name)
      trendline_name_with_parameters = add_regression_parameters_to_trendline_symbol(trendline_series_name, model_type_for_trendline)
      results.bucketed_data[trendline_name_with_parameters] = model_type_for_trendline # set model symbol
    end
  end

  def add_trendlines_for_rails_all_points
    results.series_manager.trendlines.each do |trendline_series_name|
      model_type_for_trendline = Series::ManagerBase.series_name_for_trendline(trendline_series_name)
      trendline_name_with_parameters = add_regression_parameters_to_trendline_symbol(trendline_series_name, model_type_for_trendline)
      results.bucketed_data[trendline_name_with_parameters] = Array.new(results.x_axis.length, Float::NAN)
      results.x_axis.each_with_index do |date, index|
        model_type = results.series_manager.model_type?(date)
        if model_type == model_type_for_trendline
          results.bucketed_data[trendline_name_with_parameters][index] = results.series_manager.predicted_amr_data_one_day(date)
        end
      end
    end
  end

  # find 2 extreme points for each model, add interpolated regression points
  def add_trendlines_for_rails_2_points
    series_model_types = results.bucketed_data.keys & results.series_manager.heating_model_types
    temperatures = results.bucketed_data[Series::Temperature::TEMPERATURE]
    results.series_manager.trendlines.each do |trendline_series_name|
      model_type_for_trendline = Series::ManagerBase.series_name_for_trendline(trendline_series_name)
      trendline_name_with_parameters = add_regression_parameters_to_trendline_symbol(trendline_series_name, model_type_for_trendline)
      model_temperatures_and_index = results.bucketed_data[model_type_for_trendline].each_with_index.map { | kwh, index| (kwh.nil? || kwh.nan?) ? nil : [temperatures[index], index, results.x_axis[index]] }.compact
      min, max = model_temperatures_and_index.minmax_by { |temp, _index, _date| temp }

      results.bucketed_data[trendline_name_with_parameters] = Array.new(results.x_axis.length, Float::NAN)
      results.bucketed_data[trendline_name_with_parameters][min[1]] = results.series_manager.predicted_amr_data_one_day(min[2])
      results.bucketed_data[trendline_name_with_parameters][max[1]] = results.series_manager.predicted_amr_data_one_day(max[2])
    end
  end

  def add_regression_parameters_to_trendline_symbol(trendline_symbol, model_type)
    reg = @regression_parameters[model_type]
    parameters = reg.nil? ? ' =no model' : sprintf(' =%.1fT + %.0f, r2 = %.2f, n=%d', reg[:b], reg[:a], reg[:r2], reg[:n])
    (trendline_symbol.to_s + parameters).to_sym
  end

  def calculate_regression_parameters_outside_model
    @regression_parameters = {}
    temperatures = results.bucketed_data[Series::Temperature::TEMPERATURE]
    model_names = results.bucketed_data.select { |bucket_name, _data| bucket_name != Series::Temperature::TEMPERATURE }
    model_names.each_key do |model_name|
      x_data, y_data = compact_to_non_nan_data(temperatures, results.bucketed_data[model_name])
      regression_parameters[model_name] = calculate_regression_parameters(x_data, y_data)
    end
  end

  private def compact_to_non_nan_data(temperatures, kwhs)
    x_data = []
    y_data = []
    (0...temperatures.length).each do |i|
      if !kwhs[i].nil? && !kwhs[i].nan?
        x_data.push(temperatures[i])
        y_data.push(kwhs[i])
      end
    end
    [x_data, y_data]
  end

  def calculate_regression_parameters(x_data, y_data)
    return nil if x_data.empty? || y_data.empty? # defensive: logically only 1 of these really necessary
    x = Daru::Vector.new(x_data)
    y = Daru::Vector.new(y_data)
    sr = Statsample::Regression.simple(x, y)
    { a: sr.a, b: sr.b, r2: sr.r2, n: x_data.length }
  end
end

# allows a chart to have different date range groupings on the
# x axis depending on how much data is available
# e.g. x_axis:    { 28..Float::INFINITY => :week, 4..27 => :day, 0..3 =>  :datetime},
class ChartDynamicXAxis
  def initialize(meter_collection, chart_config)
    @meter_collection = meter_collection
    @chart_config     = chart_config
  end

  def self.standard_up_to_1_year_dynamic_x_axis
    { 28..Float::INFINITY => :week, 4..27 => :day, 0..3 => :datetime}
  end

  def self.standard_solar_up_to_1_year_dynamic_x_axis
    { 56..Float::INFINITY => :month, 4..55 => :day, 0..3 => :datetime}
  end

  def self.is_dynamic?(chart_config)
    chart_config.key?(:x_axis) && chart_config[:x_axis].is_a?(Hash)
  end

  def redefined_chart_config
    clone = @chart_config.clone
    clone[:x_axis] = x_axis_grouping
    clone
  end

  private

  def x_axis_grouping
    return :year if aggregate_meter.nil?
    days_data = aggregate_meter.amr_data.days
    @chart_config[:x_axis].select{ |date_range, _v| date_range.include?(days_data) }.values[0]
  end

  def aggregate_meter
    case @chart_config[:meter_definition]
    when :allheat then @meter_collection.aggregated_heat_meters
    when :allelectricity then @meter_collection.aggregated_electricity_meters
    when :storage_heater_meter then @meter_collection.storage_heater_meter
    when :solar_pv_meter, :solar_pv then @meter_collection.aggregated_electricity_meters.sub_meters[:generation]
    when :unscaled_aggregate_target_electricity     then @meter_collection.unscaled_target_meters[:electricity]
    when :unscaled_aggregate_target_gas             then @meter_collection.unscaled_target_meters[:gas]
    when :unscaled_aggregate_target_storage_heater  then @meter_collection.unscaled_target_meters[:storage_heater]
    when :synthetic_aggregate_target_electricity    then @meter_collection.synthetic_target_meters[:electricity]
    when :synthetic_aggregate_target_gas            then @meter_collection.synthetic_target_meters[:gas]
    when :synthetic_aggregate_target_storage_heater then @meter_collection.synthetic_target_meters[:storage_heater]
    else
      raise EnergySparksUnsupportedFunctionalityException, "Dynamic x axis grouping not supported on #{@chart_config[:meter_definition]} meter_definition chart config"
    end
  end
end

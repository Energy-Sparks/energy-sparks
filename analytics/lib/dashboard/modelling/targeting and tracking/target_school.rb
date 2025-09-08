require 'require_all'
# creates a 'target' school from an existing school
# the initial implementation is the school with the
# and data shifted 1 year and then scaled by the target factor
# with an attempt to correct for holidays, but set on a per month basis or a nearby day basis
class TargetSchool < MeterCollection
  include Logging

  POTENTIAL_EXPECTED_TARGET_METER_CREATION_ERRORS = [
    TargetMeter::UnableToFindMatchingProfile,
    TargetMeter::UnableToCalculateTargetDates,
    TargetMeter::MissingGasEstimationAmrData,
    EnergySparksNotEnoughDataException,
    MissingElectricityEstimation::MoreDataAlreadyThanEstimate,
    MissingGasEstimationBase::MoreDataAlreadyThanEstimate,
    TargetDates::TargetDateBeforeFirstMeterStartDate
  ]
  NO_PARENT_METER = 'No parent meter for fuel type'
  NO_TARGET_SET   = 'No target set for fuel type'
  FIRST_TARGET_DATE_IN_FUTURE = 'first target date set after last meter reading'

  attr_reader :unscaled_target_meters, :synthetic_target_meters

  # TODO(PH, 26Oct2021) - inherit from SyntheticSchool, replace super() call
  def initialize(meter_collection, calculation_type)
    super(meter_collection.school,
          holidays:                 meter_collection.holidays,
          temperatures:             meter_collection.temperatures,
          solar_irradiation:        meter_collection.solar_irradiation,
          solar_pv:                 meter_collection.solar_pv,
          grid_carbon_intensity:    meter_collection.grid_carbon_intensity,
          pseudo_meter_attributes:  meter_collection.pseudo_meter_attributes_private)

    @original_school = meter_collection
    @unscaled_target_meters = {}
    @synthetic_target_meters = {}
    @meter_nil_reason = {}
    @aggregated_meters_by_fuel_type = {}
    @calculation_type = calculation_type
    @debug = false
  end

  def name
    "#{super} : target"
  end

  def target_school?
    true
  end

  def reason_for_nil_meter(fuel_type)
    @meter_nil_reason[fuel_type]
  end

  def aggregated_electricity_meters
    aggregated_meters_by_fuel_type(:electricity)
  end

  def aggregated_heat_meters
    aggregated_meters_by_fuel_type(:gas)
  end

  def storage_heater_meter
    aggregated_meters_by_fuel_type(:storage_heater)
  end

  private

  def aggregated_meters_by_fuel_type(fuel)
    return nil if @meter_nil_reason.key?(fuel)

    @aggregated_meters_by_fuel_type[fuel] ||= calculate_target_meter(fuel)
  end

  def calculate_target_meter(fuel_type, calculation_type = @calculation_type)
    original_meter = @original_school.aggregate_meter(fuel_type)

    debug "Calculating target meter of type #{fuel_type}".ljust(100, '-')

    target_meter = if original_meter.nil?
      set_nil_meter_with_reason(fuel_type, NO_PARENT_METER, nil)
    elsif !target_set?(original_meter)
      set_nil_meter_with_reason(fuel_type, NO_TARGET_SET, nil)
    elsif first_target_date(original_meter) > original_meter.amr_data.end_date
      set_nil_meter_with_reason(fuel_type, FIRST_TARGET_DATE_IN_FUTURE, nil)
    else
      begin
        calculate_target_meter_data(original_meter, calculation_type)
        # set_aggregate_meter(fuel_type, target_meter)
      rescue *POTENTIAL_EXPECTED_TARGET_METER_CREATION_ERRORS => e
        msg = e.is_a?(Hash) ? e : e.to_s
        set_nil_meter_with_reason(fuel_type, msg, e.class)
      end
    end

    debug "Completed calculation of target meter of type #{fuel_type}".ljust(100, '-')
    target_meter
  end

  def first_target_date(meter)
    return nil if meter.nil?
    target = TargetAttributes.new(meter)
    target.first_target_date
  end

  def set_nil_meter_with_reason(fuel_type, reason, exception_class)
    class_name = exception_class.nil? ? '' : "for #{exception_class.name}"
    fault = if reason.is_a?(Hash)
              reason
            else
              {
                text: "Setting target meter of type #{fuel_type} calculation to nil because #{reason} #{class_name}",
                type: exception_class
              }
            end

    debug fault[:text]
    @meter_nil_reason[fuel_type] = fault
    # set_aggregate_meter(fuel_type, nil)
    nil
  end

  def calculate_target_meter_data(meter, calculation_type)
    meter = TargetMeter.calculation_factory(calculation_type, meter)
    @unscaled_target_meters[meter.fuel_type] = meter.non_scaled_target_meter
    @synthetic_target_meters[meter.fuel_type] = meter.synthetic_meter
    meter
  end

  def target_set?(meter)
    !meter.nil? && meter.target_set?
  end

  def debug(var)
    logger.info var
    puts var if @debug && !Object.const_defined?('Rails')
  end
end

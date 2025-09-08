# frozen_string_literal: true

# Collection of helper methods that are used across code that aggregates
# and disaggregates meter data
module AggregationMixin
  # Sums the half-hourly meter readings within a specified time period
  #
  # If a meter doesn't have a reading within the specified period, then it is ignored
  #
  # @param Array an array of +Dashboard::Meter+
  # @param Symbol the fuel type
  # @param Date start_date
  # @param Date end_date
  # @param String mpan_mprn the meter identifier to be used when creating the new summed readings
  # @param boolean zero_negative zero negatives values
  # @returns AmrData a new time series populated with the combined data
  def aggregate_amr_data_between_dates(meters, type, start_date, end_date, mpan_mprn, zero_negative: false)
    combined_amr_data = AMRData.new(type)
    (start_date..end_date).each do |date|
      valid_meters_for_date = meters.select { |meter| meter.amr_data.date_exists?(date) }
      amr_data_for_date_x48_valid_meters = valid_meters_for_date.map { |meter| meter.amr_data.days_kwh_x48(date) }
      combined_amr_data_x48 = AMRData.fast_add_multiple_x48_x_x48(amr_data_for_date_x48_valid_meters)
      combined_amr_data_x48.map! { |v| [v, 0.0].max } if zero_negative
      days_data = OneDayAMRReading.new(mpan_mprn, date, 'ORIG', nil, DateTime.now, combined_amr_data_x48)
      combined_amr_data.add(date, days_data)
    end
    combined_amr_data
  end

  # Takes a list of meters and determines a date range that has coverage across
  # all of the meters.
  #
  # If there are no aggregation rules, or there are disabled using the +ignore_rules+ parameter,
  # the default is to calculate the date range across which all the time series
  # overlap
  #
  # The processing rules can be used to configure how the final range is determined,
  # to allow for the fact that the meters may have non-overlapping, or only
  # partly overlapping date ranges.
  #
  # E.g. because a meter has been replaced, decommissioned, or has only just been
  # brought into service.
  #
  # @param Array meters a list of +Dashboard::Meter+ objects
  # @param boolean ignore_rules
  # @return Array returns an array containing start date, end date
  def combined_amr_data_date_range(meters, ignore_rules)
    if ignore_rules
      combined_amr_data_date_range_no_rules(meters)
    else
      combined_amr_data_date_range_with_rules(meters)
    end
  end

  # @return Array returns an array containing start date, end date
  def combined_amr_data_date_range_no_rules(meters)
    [
      meters.map { |m| m.amr_data.start_date }.max,
      meters.map { |m| m.amr_data.end_date   }.min
    ]
  end

  # Calculates a combined meter range, obeying a set of aggregation rules
  # configured as meter attributes
  #
  # There are rules indicating that either the start date and/or end date for a
  # meter should be ignored when calculating a combined range.
  #
  # There's no difference between the two different versions of each rule other than
  # to communicate that a meter is no longer used ("deprecated" = "decommissioned").
  #
  # @return Array returns an array containing start date, end date
  def combined_amr_data_date_range_with_rules(meters)
    start_dates = []
    end_dates = []
    meters.each do |meter|
      aggregation_rules = meter.attributes(:aggregation)
      if aggregation_rules.nil?
        start_dates.push(meter.amr_data.start_date)
      elsif !(aggregation_rules.include?(:ignore_start_date) ||
              aggregation_rules.include?(:deprecated_include_but_ignore_start_date))
        start_dates.push(meter.amr_data.start_date)
      end
      if aggregation_rules.nil?
        end_dates.push(meter.amr_data.end_date)
      elsif !(aggregation_rules.include?(:ignore_end_date) ||
        aggregation_rules.include?(:deprecated_include_but_ignore_end_date))
        end_dates.push(meter.amr_data.end_date)
      end
    end
    [start_dates.max, end_dates.min]
  end

  private

  # Aggregate the data associated with a list of meters, optionally ignoring any aggregation rules
  #
  # @param Array meter an array of +Dashboard::Meter+
  # @param Symbol type the fuel type
  # @param boolean ignore_rules whether to ignore rules specifying how start/end dates of meters are handled
  # @returns AmrData a new AmrData instance that holds the aggregate series of meter readings
  def aggregate_amr_data(meters, type, ignore_rules: false, zero_negative: false)
    if meters.length == 1
      logger.info 'Single meter, so aggregation is a reference to itself not an aggregate meter'
      return meters.first.amr_data # optimisaton if only 1 meter, then its its own aggregate
    end
    min_date, max_date = combined_amr_data_date_range(meters, ignore_rules)

    # If all meters have an ignore_start_date or ignore_end_date attribute we end up with null dates, so check and throw exception
    raise EnergySparksUnexpectedStateException, 'Invalid AMR date range. Cannot calculate start date. Ensure at least one meter does not have ignore_start_date attribute' if min_date.nil?
    raise EnergySparksUnexpectedStateException, 'Invalid AMR date range. Cannot calculate end date. Ensure at least one meter does not have ignore_end_date attribute' if max_date.nil?
    # This can happen if there are 2 meter, with non-overlapping date ranges
    # Without a check, the renaming code is run but we end up with an aggregate meter that
    # contains no readings and has default dates from HalfHourlyData.new. This can cause errors elsewhere as other
    # code does not check for the dates or if there are no readings.
    raise EnergySparksUnexpectedStateException, "Invalid AMR date range. Minimum date (#{min_date}) after maximum date (#{max_date}) unable to aggregate data" if min_date > max_date

    logger.info "Aggregating data between #{min_date} and #{max_date}"

    mpan_mprn = Dashboard::Meter.synthetic_combined_meter_mpan_mprn_from_urn(meter_collection.urn, meters[0].fuel_type) unless meter_collection.urn.nil?

    aggregate_amr_data_between_dates(meters, type, min_date, max_date, mpan_mprn, zero_negative: zero_negative)
  end

  # Triggers the calculation and caching of co2 emissions for a meter
  # Results in the underlying +AmrData+ object holding a schedule of co2 emissions data
  #
  # If this is not called, then the +AmrData+ object will not be able to correctly return
  # co2 values for a given day or period
  def calculate_carbon_emissions_for_meter(meter, fuel_type)
    if %i[electricity aggregated_electricity].include?(fuel_type) # TODO(PH, 6Apr19) remove : aggregated_electricity once analytics meter meta data loading changed
      meter.amr_data.set_carbon_emissions(meter.id, nil, meter_collection.grid_carbon_intensity)
    else
      meter.amr_data.set_carbon_emissions(meter.id, EnergyEquivalences.co2_kg_kwh(:gas), nil)
    end
  end

  # Triggers the calculation of tariffs for a meter
  # Results in the underlying +AmrData+ object holding a schedule of cost data
  #
  # If this is not called, then the +AmrData+ object will not be able to correctly return
  # cost values for a given day or period
  def calculate_costs_for_meter(meter)
    logger.info "Creating economic & accounting costs for #{meter.mpan_mprn} fuel #{meter.fuel_type} from #{meter.amr_data.start_date} to #{meter.amr_data.end_date}"
    meter.set_tariffs
  end

  def calculate_meter_carbon_emissions_and_costs(meter, fuel_type)
    calculate_carbon_emissions_for_meter(meter, fuel_type)
    calculate_costs_for_meter(meter)
  end

  def calculate_meters_carbon_emissions_and_costs(meters, fuel_type)
    meters.each do |meter|
      calculate_meter_carbon_emissions_and_costs(meter, fuel_type)
    end
  end
end

# Can be included by comparison models that have attributes for multiple fuel types
# and units across two different periods (current and previous)
#
# e.g. electricity_previous_period_kwh
#
# Assumes, by default that fields are named according to +field_name+ but this can be
# overridden
module MultipleFuelComparisonView
  extend ActiveSupport::Concern

  DEFAULT_UNITS = %i[kwh co2 gbp].freeze
  DEFAULT_FUEL_TYPES = %i[electricity gas storage_heater].freeze

  def total_percentage_change_kwh
    total_percentage_change(unit: :kwh)
  end

  # Returns total consumption for +unit+ in the current period
  #
  # Simply totals the values across all kwh fields for each fuel type
  def total_current_period(unit: :kwh)
    all_current_period(unit: unit).sum(&:to_f)
  end

  # Returns total consumption for +unit+ in the current period
  #
  # By default the method assumes that the total will be used in a comparison with
  # the previous period and operates a "strict" policy for calculating the totals.
  #
  # Strict mode means a total is only returned if we have values for both electricity and
  # gas in both years. Otherwise we assume data is incomplete and we return nil
  #
  # Change the model value to just return a simple sum
  #
  # See EnergySparks::Calculator.sum_if_complete
  def total_previous_period(unit: :kwh, mode: :strict)
    return all_previous_period(unit: unit).sum unless mode == :strict
    EnergySparks::Calculator.sum_if_complete(all_previous_period(unit: unit), all_current_period(unit: unit))
  end

  # Calculate percentage change, for a specific unit across the two periods
  def total_percentage_change(unit:)
    EnergySparks::Calculator.percent_change(total_previous_period(unit: unit), total_current_period(unit: unit))
  end

  # Returns an array of values for the specified unit, for the previous period
  # E.g. by calling :electricity_previous_period_kwh, :gas_previous_period_kwh, etc
  def all_previous_period(unit: :kwh)
    field_names(period: :previous_period, unit: unit).map do |field|
      send(field)
    end
  end

  # Returns an array of values for the specified unit, for the current period
  # E.g. by calling :electricity_current_period_kwh, :gas_current_period_kwh, etc
  def all_current_period(unit: :kwh)
    field_names(period: :current_period, unit: unit).map do |field|
      send(field)
    end
  end

  def field_names(period: :previous_period, unit: :kwh)
    unit = :gbp if unit == :£
    field_names = []
    fuel_types.each do |fuel_type|
      field_names << field_name(fuel_type, period, unit)
    end
    field_names
  end

  private

  def units
    DEFAULT_UNITS
  end

  def fuel_types
    DEFAULT_FUEL_TYPES
  end

  def field_name(fuel_type, period, unit)
    :"#{fuel_type}_#{period}_#{unit}"
  end
end

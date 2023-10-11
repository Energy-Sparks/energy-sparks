module Measurements
  extend ActiveSupport::Concern

  MEASUREMENT_OPTIONS = ActiveSupport::HashWithIndifferentAccess.new(
    kwh: 'energy used in kilowatt-hours',
    gb_pounds: 'energy cost in pounds',
    co2: 'carbon dioxide in kilograms produced'
  ).freeze

  def set_measurement_options
    @measurement_options = MEASUREMENT_OPTIONS
    @default_measurement = :kwh
  end

  def measurement_unit(measurement_parameter)
    if valid_measurement?(measurement_parameter)
      # Set cookie
      set_cookie_preference(measurement_parameter)
    else
      default_measurement_or_preference
    end
  end

  private

  def valid_measurement?(measurement)
    measurement && MEASUREMENT_OPTIONS.key?(measurement)
  end

  def default_measurement_or_preference
    cookie_value = cookies[:energy_sparks_measurement]
    if valid_measurement?(cookie_value)
      cookie_value
    else
      @default_measurement
    end
  end

  def set_cookie_preference(measurement)
    cookies[:energy_sparks_measurement] = measurement
    measurement
  end
end

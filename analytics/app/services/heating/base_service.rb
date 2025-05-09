# frozen_string_literal: true

module Heating
  # Base class for heating services that need to create a heating model
  class BaseService
    ONE_WEEK = 7

    def initialize(meter_collection, asof_date, fuel_type = :gas)
      validate_meter_collection(meter_collection)
      @meter_collection = meter_collection
      @asof_date = asof_date
      @fuel_type = fuel_type
    end

    # Confirms that we are able to successfully generate a heating model from this school's
    # data.
    def enough_data?
      enough_data_for_model_fit? && heating_model.includes_school_day_heating_models?
    end

    # Generally need at least a year of data to fit a model, but
    # not clear what the minimum might be. So default to returning nil
    def data_available_from
      nil
    end

    def validate_meter_collection(meter_collection)
      raise EnergySparksUnexpectedStateException, 'School does not have gas meters' if @fuel_type == :gas && meter_collection.aggregated_heat_meters.nil?
      return unless @fuel_type == :gas && meter_collection.aggregated_heat_meters.non_heating_only?

      raise EnergySparksUnexpectedStateException, 'School does not use gas for heating'
    end

    def aggregate_meter
      @aggregate_meter ||= @fuel_type == :storage_heater ? @meter_collection.storage_heater_meter : @meter_collection.aggregated_heat_meters
    end

    def enough_data_for_model_fit?
      heating_model.enough_samples_for_good_fit
    # FIXME: NoMethodError caught here as it was in original code,
    # but not sure why that's the case. Keeping for now
    rescue EnergySparksNotEnoughDataException, NoMethodError
      false
    end

    def heating_model
      @heating_model ||= create_and_fit_model
    end

    private

    def create_and_fit_model
      HeatingModelFactory.new(aggregate_meter, @asof_date).create_model
    end

    def meter_date_range_checker
      @meter_date_range_checker ||= Util::MeterDateRangeChecker.new(aggregate_meter, @asof_date)
    end
  end
end

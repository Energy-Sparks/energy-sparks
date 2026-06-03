# frozen_string_literal: true

module Heating
  class HeatingThermostaticAnalysisService < BaseService
    def initialize(
      meter_collection:,
      average_outside_temperature_high_centigrade: 12.0,
      average_outside_temperature_low_centigrade: 4.0,
      fuel_type: :gas
    )
      raise 'Invalid fuel type' unless %i[gas storage_heater].include? fuel_type

      validate_meter_collection(meter_collection)
      @meter_collection = meter_collection
      @average_outside_temperature_high_centigrade = average_outside_temperature_high_centigrade
      @average_outside_temperature_low_centigrade = average_outside_temperature_low_centigrade
      @fuel_type = fuel_type
    end

    # def data_available_from
    # end

    def create_model
      OpenStruct.new(
        r2: r2,
        insulation_hotwater_heat_loss_estimate_kwh: insulation_hotwater_heat_loss_estimate_kwh,
        insulation_hotwater_heat_loss_estimate_£: insulation_hotwater_heat_loss_estimate_£,
        average_heating_school_day_a: average_heating_school_day_a,
        average_heating_school_day_b: average_heating_school_day_b,
        average_outside_temperature_high: @average_outside_temperature_high_centigrade,
        average_outside_temperature_low: @average_outside_temperature_low_centigrade,
        predicted_kwh_for_high_average_outside_temperature: predicted_kwh(@average_outside_temperature_high_centigrade),
        predicted_kwh_for_low_average_outside_temperature: predicted_kwh(@average_outside_temperature_low_centigrade)
      )
    end

    private

    def average_heating_school_day_a
      heating_model.average_heating_school_day_a
    end

    def average_heating_school_day_b
      heating_model.average_heating_school_day_b
    end

    def predicted_kwh(temperature)
      a + b * temperature
    end

    def latest_blended_tariff_£_per_kwh
      aggregate_meter.amr_data.current_tariff_rate_£_per_kwh
    end

    def insulation_hotwater_heat_loss_estimate_£
      insulation_hotwater_heat_loss_estimate_kwh * latest_blended_tariff_£_per_kwh
    end

    def insulation_hotwater_heat_loss_estimate_kwh
      loss_kwh, _percent_loss = heating_model.hot_water_poor_insulation_cost_kwh(
        one_year_before_last_meter_date,
        last_meter_date
      )
      loss_kwh
    end

    def one_year_before_last_meter_date
      [last_meter_date - 364, aggregate_meter.amr_data.start_date].max
    end

    def last_meter_date
      aggregate_meter.amr_data.end_date
    end

    def a
      heating_model.average_heating_school_day_a
    end

    def b
      heating_model.average_heating_school_day_b
    end

    def calculate_heating_model
      # Use simple_regression_temperature rather than best model for the explanation
      # otherwise the chart is too complicated for most
      # users to understand if the thermally massive model is used
      start_date = [aggregate_meter.amr_data.end_date - 364, aggregate_meter.amr_data.start_date].max
      last_year = SchoolDatePeriod.new(:analysis, 'validate amr', start_date, aggregate_meter.amr_data.end_date)
      aggregate_meter.heating_model(last_year, :simple_regression_temperature)
    end

    def heating_model
      @heating_model ||= calculate_heating_model
    end

    def r2
      heating_model.average_heating_school_day_r2
    end
  end
end

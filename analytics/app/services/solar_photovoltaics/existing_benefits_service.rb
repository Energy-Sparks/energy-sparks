# frozen_string_literal: true

module SolarPhotovoltaics
  class ExistingBenefitsService
    def initialize(meter_collection:)
      @meter_collection = meter_collection

      raise unless @meter_collection.solar_pv_panels?
    end

    def create_model
      OpenStruct.new(
        annual_saving_from_solar_pv_percent: solar_pv_profit_loss.annual_saving_from_solar_pv_percent,
        annual_carbon_saving_percent: solar_pv_profit_loss.annual_carbon_saving_percent,
        annual_electricity_including_onsite_solar_pv_consumption_kwh: solar_pv_profit_loss.annual_electricity_including_onsite_solar_pv_consumption_kwh,
        annual_consumed_from_national_grid_kwh: solar_pv_profit_loss.annual_consumed_from_national_grid_kwh,
        saving_£current: saving_£current,
        export_£: export_£,
        annual_co2_saving_kg: solar_pv_profit_loss.annual_co2_saving_kg,
        annual_solar_pv_kwh: solar_pv_profit_loss.annual_solar_pv_kwh,
        annual_exported_solar_pv_kwh: solar_pv_profit_loss.annual_exported_solar_pv_kwh,
        annual_solar_pv_consumed_onsite_kwh: solar_pv_profit_loss.annual_solar_pv_consumed_onsite_kwh
      )
    end

    def enough_data?
      meter_data_checker.one_years_data?
    end

    # If we don't have enough data, then when will it be available?
    def data_available_from
      meter_data_checker.date_when_enough_data_available(365)
    end

    private

    def aggregated_electricity_meters
      @aggregated_electricity_meters ||= @meter_collection.aggregated_electricity_meters
    end

    def meter_data_checker
      @meter_data_checker ||= Util::MeterDateRangeChecker.new(aggregated_electricity_meters, aggregated_electricity_meters.amr_data.end_date)
    end

    def export_£
      solar_pv_profit_loss.annual_exported_solar_pv_kwh * BenchmarkMetrics.pricing.solar_export_price
    end

    def saving_£current
      solar_pv_profit_loss.annual_solar_pv_consumed_onsite_kwh * electricity_price_£current_per_kwh
    end

    def electricity_price_£current_per_kwh
      @meter_collection.aggregated_electricity_meters.amr_data.blended_rate(:kwh, :£current).round(5)
    end

    def solar_pv_profit_loss
      @solar_pv_profit_loss = SolarPVProfitLoss.new(@meter_collection)
    end
  end
end

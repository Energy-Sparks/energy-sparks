# frozen_string_literal: true

module Costs
  class AgreedSupplyCapacityService
    include AnalysableMixin

    def initialize(analytics_meter, asof_date = analytics_meter.amr_data.end_date)
      @meter = analytics_meter
      @asof_date = asof_date
      @accounting_tariff = @meter.meter_tariffs.accounting_tariff_for_date(@asof_date)
    end

    def enough_data?
      !@accounting_tariff.nil? && !asc_limit_kw.nil?
    end

    def summarise
      return nil unless enough_data?
      return nil if agreed_availability_charge.nil?

      kw = agreed_supply_capacity_requirement_kw
      cost_£ = 12.0 * asc_limit_kw * agreed_availability_charge[:rate]
      saving_£ = (1.0 - kw / asc_limit_kw) * cost_£
      AgreedSupplyCapacitySummary.new(
        kw: kw,
        agreed_limit_kw: @accounting_tariff.tariff[:asc_limit_kw],
        annual_cost_£: cost_£,
        annual_saving_£: saving_£
      )
    end

    private

    def asc_limit_kw
      @accounting_tariff.tariff[:asc_limit_kw]
    end

    def agreed_availability_charge
      @accounting_tariff.tariff[:rates][:agreed_availability_charge]
    end

    def start_date
      [@asof_date - 365, @meter.amr_data.start_date].max
    end

    def agreed_supply_capacity_requirement_kw
      @meter.amr_data.peak_kw_date_range_with_dates(start_date, @asof_date).values[0]
    end
  end
end

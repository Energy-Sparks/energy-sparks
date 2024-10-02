# frozen_string_literal: true

module SolarPhotovoltaics
  class PotentialBenefitsEstimatorService
    include AnalysableMixin

    attr_reader :scenarios, :optimum_kwp, :optimum_payback_years, :optimum_mains_reduction_percent

    def initialize(meter_collection:, asof_date: Date.today)
      @meter_collection = meter_collection
      raise if @meter_collection.solar_pv_panels?

      @asof_date = asof_date
    end

    def create_model
      # find the optimum payback period
      optimum_kwp = calculate_optimum_kwp(@asof_date)
      # calculate costs/benefits for range of scenarios, including the optimum
      # sets @scenarios
      calculate_scenarios(@asof_date, optimum_kwp)
      # sets @optimum_kwp, @optimum_payback_years, @optimum_mains_reduction_percent
      set_optimum_values(optimum_kwp)

      OpenStruct.new(
        optimum_kwp: @optimum_kwp,
        optimum_payback_years: @optimum_payback_years,
        optimum_mains_reduction_percent: @optimum_mains_reduction_percent,
        scenarios: @scenarios
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

    def meter_data_checker
      @meter_data_checker ||= Util::MeterDateRangeChecker.new(aggregated_electricity_meters, @asof_date)
    end

    def aggregated_electricity_meters
      @aggregated_electricity_meters ||= @meter_collection.aggregated_electricity_meters
    end

    def set_optimum_values(optimum_kwp)
      optimum_scenario = find_optimum_kwp(@scenarios, round_optimum_kwp(optimum_kwp))
      @optimum_kwp = optimum_scenario[:kwp]
      @optimum_payback_years = optimum_scenario[:payback_years]
      @optimum_mains_reduction_percent = optimum_scenario[:reduction_in_mains_percent]
    end

    def calculate_scenarios(date, optimum_kwp)
      @scenarios = []

      kwp_scenario_including_optimum(optimum_kwp).each do |kwp|
        solar_pv_benefit_results = calculate_solar_pv_benefit(date, kwp)
        economic_benefit_results = calculate_economic_benefit(solar_pv_benefit_results)

        @scenarios << OpenStruct.new(
          solar_pv_benefit_results.merge(economic_benefit_results)
        )
      end
    end

    def kwp_scenario_including_optimum(optimum_kwp)
      optimum = round_optimum_kwp(optimum_kwp)
      kwp_scenario_ranges.push(optimum).sort.uniq(&:to_f)
    end

    def round_optimum_kwp(kwp)
      (kwp * 2.0).round(0) / 2.0
    end

    def kwp_scenario_ranges
      (0..8).each_with_object([]) do |p, capacity_rows|
        capacity_rows.push(2**p) if 2**p < max_possible_kwp
      end
    end

    def find_optimum_kwp(rows, optimum_kwp)
      rows.find { |row| row[:kwp] == optimum_kwp }
    end

    def calculate_optimum_kwp(date)
      optimum = Minimiser.minimize(1, max_possible_kwp) { |kwp| payback(kwp, date) }
      optimum.x_minimum
    end

    def payback(kwp, date)
      kwh_data = calculate_solar_pv_benefit(date, kwp)
      calculate_economic_benefit(kwh_data)[:payback_years]
    end

    def calculate_solar_pv_benefit(date, kwp)
      # NOTE: this code is copied from existing code in AlertSolarPVBenefitEstimator and needs refactoring (see rubocop comment)
      start_date = date - 365
      kwh_totals = estimate_consumption(start_date, date, kwp)

      kwh = existing_annual_kwh(start_date, date)
      £ = existing_annual_£(start_date, date)

      {
        kwp: kwp,
        panels: number_of_panels(kwp),
        area: panel_area_m2(number_of_panels(kwp)),
        existing_annual_kwh: kwh,
        existing_annual_£: £,
        new_mains_consumption_kwh: kwh_totals[:new_mains_consumption],
        new_mains_consumption_£: kwh_totals[:new_mains_consumption_£],
        reduction_in_mains_percent: (kwh - kwh_totals[:new_mains_consumption]) / kwh,
        solar_consumed_onsite_kwh: kwh_totals[:solar_consumed_onsite],
        exported_kwh: kwh_totals[:exported],
        solar_pv_output_kwh: kwh_totals[:solar_pv_output],
        solar_pv_output_co2: kwh_totals[:solar_pv_output] * blended_co2_per_kwh
      }
    end

    def existing_annual_kwh(start_date, end_date)
      aggregated_electricity_meters.amr_data.kwh_date_range(start_date, end_date)
    end

    def existing_annual_£(start_date, end_date)
      aggregated_electricity_meters.amr_data.kwh_date_range(start_date, end_date, :£current)
    end

    def estimate_consumption(start_date, date, kwp)
      pv_panels.annual_predicted_pv_totals_fast(aggregated_electricity_meters.amr_data, @meter_collection, start_date, date, kwp)
    end

    def pv_panels
      ConsumptionEstimator.new
    end

    def blended_co2_per_kwh
      @blended_co2_per_kwh ||= ::Costs::BlendedRateCalculator.new(aggregated_electricity_meters).blended_co2_per_kwh
    end

    def calculate_economic_benefit(kwh_data)
      new_mains_cost = kwh_data[:new_mains_consumption_£]
      old_mains_cost = kwh_data[:existing_annual_£]
      export_income  = kwh_data[:exported_kwh] * BenchmarkMetrics.pricing.solar_export_price

      mains_savings   = old_mains_cost - new_mains_cost
      saving          = mains_savings + export_income

      capital_cost    = capital_costs(kwh_data[:kwp])
      payback         = capital_cost / saving

      {
        old_mains_cost_£: old_mains_cost,
        new_mains_cost_£: new_mains_cost,
        export_income_£: export_income,
        mains_savings_£: mains_savings,
        total_annual_saving_£: saving,
        total_annual_saving_co2: kwh_data[:solar_pv_output_co2],
        capital_cost_£: capital_cost,
        payback_years: payback
      }
    end

    def capital_costs(kwp)
      # Costs estimated using range of data provided by Egni, BWCE, Ebay
      # See internal analysis spreadsheet. Updated 2023-06-09
      kwp == 0.0 ? 0.0 : (1584 * kwp**0.854)
    end

    def number_of_panels(kwp)
      # assume 300 Wp per panel
      (kwp / 0.300).round(0).to_i
    end

    def panel_area_m2(panels)
      (panels * 1.6 * 0.9).round(0)
    end

    def max_possible_kwp
      # 25% of floor area, 6m2 panels/kWp
      @max_possible_kwp ||= (@meter_collection.floor_area * 0.25) / 6.0
    end
  end
end

module AnalyseHeatingAndHotWater
  class HotWaterInvestmentAnalysis
    PUPILS_PER_POINT_OF_USE_HOTWATER_HEATER = 20.0
    STANDING_LOSS_FROM_ELECTRIC_WATER_HEATER_KWH_PER_DAY = 0.35
    CAPITAL_COST_POU_ELECTRIC_HEATER = 200.0
    INSTALL_COST_POU_ELECTRIC_HEATER = 200.0
    attr_reader :hotwater_model
    def initialize(school)
      @school = school
      @hotwater_model = HotwaterModel.new(@school)
      @theoretical_hw_kwh, _standing_loss_kwh, _total_kwh = self.class.annual_point_of_use_electricity_meter_kwh(@school.number_of_pupils)
    end

    def enough_data?
      # As per AlertHotWaterEfficiency#enough_data
      @hotwater_model.find_period_before_and_during_summer_holidays(
        @school.holidays, @school.aggregated_heat_meters.amr_data
      ).present?
    end

    def analyse_annual
      current = existing_gas_estimates
      {
        existing_gas:           current,
        gas_better_control:     calculate_saving(current, gas_better_control),
        point_of_use_electric:  calculate_saving(current, point_of_use_hotwater_economics)
      }
    end

    private def calculate_gas_efficiency(annual, current, gas_better_control)
      annual[:existing_gas][:efficiency] = @theoretical_hw_kwh / current[:annual_kwh]
      annual[:gas_better_control][:efficiency] = @theoretical_hw_kwh / gas_better_control[:annual_kwh]
    end

    private def calculate_saving(base_line, proposal)
      saving_kwh, saving_kwh_percent  = saving_and_percent(base_line[:annual_kwh], proposal[:annual_kwh])
      saving_£, saving_£_percent      = saving_and_percent(base_line[:annual_£],   proposal[:annual_£])
      saving_co2, saving_co2_percent  = saving_and_percent(base_line[:annual_co2], proposal[:annual_co2])
      payback_years = proposal[:capex] == 0.0 ? 0.0 : (proposal[:capex] / saving_£)
      {
        saving_kwh:         saving_kwh,
        saving_kwh_percent: saving_kwh_percent,
        saving_£:           saving_£,
        saving_£_percent:   saving_£_percent,
        saving_co2:         saving_co2,
        saving_co2_percent: saving_co2_percent,
        payback_years:      payback_years
      }.merge(proposal)
    end

    private def saving_and_percent(baseline, proposal)
      saving = baseline - proposal
      [saving, saving / baseline]
    end

    private def efficiency(kwh)
      @theoretical_hw_kwh / kwh
    end

    private def existing_gas_estimates
      total_kwh = @hotwater_model.annual_hotwater_kwh_estimate
      {
        annual_kwh:   total_kwh,
        annual_£:     total_kwh * gas_price_£_per_kwh,
        annual_co2:   total_kwh * EnergyEquivalences::UK_GAS_CO2_KG_KWH,
        capex:        0.0,
        efficiency:   efficiency(total_kwh)
      }
    end

    private def gas_better_control
      total_kwh = @hotwater_model.annual_hotwater_kwh_estimate_better_control
      {
        annual_kwh:    total_kwh,
        annual_£:      total_kwh * gas_price_£_per_kwh,
        annual_co2:    total_kwh * EnergyEquivalences::UK_GAS_CO2_KG_KWH,
        capex:         0.0,
        efficiency:    efficiency(total_kwh)
      }
    end

    private def point_of_use_hotwater_economics
      @theoretical_hw_kwh, standing_loss_kwh, total_kwh = self.class.annual_point_of_use_electricity_meter_kwh(@school.number_of_pupils)
      {
        annual_kwh:   total_kwh,
        annual_£:     total_kwh * electric_price_£_per_kwh,
        annual_co2:   total_kwh * BenchmarkMetrics::LONG_TERM_ELECTRICITY_CO2_KG_PER_KWH,
        capex:        point_of_use_electric_heaters_capex,
        efficiency:   efficiency(total_kwh)
      }
    end

    private def gas_price_£_per_kwh
      @gas_price_£_per_kwh ||= @school.aggregated_heat_meters.amr_data.blended_rate(:kwh, :£current)
    end

    # school may have gas only, so estimate using default electricity tariff
    private def defaulted_electricity_tariff_£_per_kwh
      if @school.aggregated_electricity_meters.nil?
        BenchmarkMetrics.pricing.electricity_price
      else
        @school.aggregated_electricity_meters.amr_data.blended_rate(:kwh, :£current).round(5)
      end
    end

    private def electric_price_£_per_kwh
      @electric_price_£_per_kwh ||= defaulted_electricity_tariff_£_per_kwh
    end

    private def point_of_use_electric_heaters_capex
      number_of_heaters = self.class.estimated_number_pou_heaters(@school.number_of_pupils)
      number_of_heaters * (CAPITAL_COST_POU_ELECTRIC_HEATER + INSTALL_COST_POU_ELECTRIC_HEATER)
    end

    def self.estimated_number_pou_heaters(pupils, pupils_per_point_of_use_hotwater_heater = PUPILS_PER_POINT_OF_USE_HOTWATER_HEATER)
      (pupils / pupils_per_point_of_use_hotwater_heater).ceil
    end

    def self.annual_point_of_use_electricity_meter_kwh(pupils, pupils_per_point_of_use_hotwater_heater = PUPILS_PER_POINT_OF_USE_HOTWATER_HEATER)
      standing_loss = estimated_number_pou_heaters(pupils) * STANDING_LOSS_FROM_ELECTRIC_WATER_HEATER_KWH_PER_DAY * 365
      hot_water_usage = HotwaterModel.benchmark_annual_pupil_kwh * pupils
      [hot_water_usage, standing_loss, hot_water_usage + standing_loss]
    end
  end
end
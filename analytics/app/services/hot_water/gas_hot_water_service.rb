# frozen_string_literal: true

module HotWater
  class GasHotWaterService
    include AnalysableMixin

    def initialize(meter_collection:)
      @meter_collection = meter_collection
    end

    def create_model
      OpenStruct.new(
        investment_choices: investment_choices,
        efficiency_breakdowns: efficiency_breakdowns
      )
    end

    def enough_data?
      investment_analysis.enough_data?
    rescue StandardError
      # Rescues from error raised in AnalyseHeatingAndHotWater::HotwaterModel#analyse_hotwater_around_summer_holidays:
      # 'Meter data does not cover a period starting before and including a sumer holiday - unable to complete hot water efficiency analysis'
      false
    end

    private

    def investment_analysis
      @investment_analysis ||= AnalyseHeatingAndHotWater::HotWaterInvestmentAnalysis.new(@meter_collection)
    end

    def investment_analysis_annual
      # Returns a hash of investment choices: existing gas, gas better control, and point of use electric
      investment_analysis.analyse_annual
    end

    def investment_choices
      investment_analysis_annual.each_with_object(OpenStruct.new) do |(type, values), investment_choices|
        investment_choices[type] = OpenStruct.new(values)
      end
    end

    def hotwater_model
      investment_analysis.hotwater_model
    end

    def efficiency_breakdowns
      hotwater_analysis.each_with_object(OpenStruct.new) do |(type, values_for_type), efficiency_breakdown|
        efficiency_breakdown[type] = build_efficiency_breakdown(values_for_type)
      end
    end

    def build_efficiency_breakdown(values_for_type)
      efficiency_breakdown = OpenStruct.new
      values_for_type.map { |row, value| efficiency_breakdown[row] = OpenStruct.new(value) }
      efficiency_breakdown
    end

    def hotwater_analysis
      hotwater_model.daytype_breakdown_statistics
    end
  end
end

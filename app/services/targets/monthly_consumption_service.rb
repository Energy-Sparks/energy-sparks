# frozen_string_literal: true

module Targets
  class MonthlyConsumptionService
    attr_reader :consumption

    def initialize(target, fuel_type)
      @target = target
      @fuel_type = fuel_type
      @consumption = target&.monthly_consumption(fuel_type)
    end

    def self.any_missing?(target)
      SchoolTarget::FUEL_TYPES.any? do |fuel_type|
        !target.public_send(fuel_type).nil? && new(target, fuel_type).any_missing?
      end
    end

    def non_missing
      @non_missing ||= @consumption&.reject { |month| month[:missing] }
    end

    def current_consumption
      @current_consumption ||= non_missing&.sum { |month| month[:current_consumption] }
    end

    def target_consumption
      @target_consumption ||= non_missing&.sum { |month| month[:target_consumption] }
    end

    def meeting_target
      return nil if @target.nil?

      analysis_dates = Schools::AnalysisDates.new(@target.school, @fuel_type)
      if [*@consumption&.pluck(:previous_consumption), analysis_dates.analysis_date,
          current_consumption, target_consumption].any?(&:nil?) ||
         !analysis_dates.recent_data
        return
      end

      current_consumption <= target_consumption
    end

    def any_missing?
      @consumption.nil? || @consumption.any? { |month| month[:previous_missing] }
    end
  end
end

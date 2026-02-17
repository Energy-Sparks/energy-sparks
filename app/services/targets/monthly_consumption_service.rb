# frozen_string_literal: true

module Targets
  # used to calculate monthly consumptions figures for the long term advice page
  class MonthlyConsumptionService
    attr_reader :consumption, :non_missing

    def initialize(target, fuel_type)
      @target = target
      @fuel_type = fuel_type
      @consumption = target&.monthly_consumption(fuel_type)
      @non_missing = @consumption&.reject { |month| month[:missing] }
    end

    def self.any_missing?(target)
      SchoolTarget::FUEL_TYPES.any? do |fuel_type|
        !target&.public_send(fuel_type).nil? && new(target, fuel_type).any_missing?
      end
    end

    def current_consumption
      sum_non_missing(:current_consumption)
    end

    def target_consumption
      sum_non_missing(:target_consumption)
    end

    def meeting_target
      cache(:meeting_target) do
        return if @target.nil?

        analysis_dates = Schools::AnalysisDates.new(@target.school, @fuel_type)
        if [*@consumption&.pluck(:previous_consumption), analysis_dates.analysis_date,
            current_consumption, target_consumption].any?(&:nil?) ||
           !analysis_dates.recent_data
          return
        end

        current_consumption <= target_consumption
      end
    end

    def any_missing?
      @consumption.nil? || @consumption.any? { |month| month[:previous_missing] }
    end

    private

    def cache(name)
      name = "@#{name}"
      instance_variable_defined?(name) ? instance_variable_get(name) : instance_variable_set(name, yield)
    end

    def sum_non_missing(type)
      cache(type) do
        non_missing&.sum { |month| month[type] } if @non_missing.present?
      end
    end
  end
end

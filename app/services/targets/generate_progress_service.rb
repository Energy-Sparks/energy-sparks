# frozen_string_literal: true

module Targets
  class GenerateProgressService
    def initialize(school, aggregated_school)
      @school = school
      @aggregated_school = aggregated_school
      @progress_by_fuel_type = {}
      @reported_errors = {}
    end

    def generate!
      return unless Targets::SchoolTargetService.targets_enabled?(@school) && target.present?

      @school.school_targets.find_each do |target|
        update_monthly_consumption(target) unless target_complete?(target)
      end
      target
    end

    def update_monthly_consumption(target)
      target.update!(
        electricity_monthly_consumption: calculate_monthly_consumption(:electricity, target),
        gas_monthly_consumption: calculate_monthly_consumption(:gas, target),
        storage_heaters_monthly_consumption: calculate_monthly_consumption(:storage_heaters, target),
        report_last_generated: Time.zone.now
      )
    end

    private

    def target_complete?(target)
      %i[electricity gas storage_heaters].all? do |fuel_type|
        if fuel_type_and_target?(fuel_type, target)
          consumption_complete?(fuel_type, target)
        else
          true
        end
      end
    end

    def consumption_complete?(fuel_type, target)
      target.monthly_consumption(fuel_type)&.all? { |month| month[:missing] == false }
    end

    def calculate_monthly_consumption(fuel_type, target)
      return nil unless fuel_type_and_target?(fuel_type, target) && @aggregated_school.aggregate_meter(fuel_type)

      return target["#{fuel_type}_monthly_consumption"] if consumption_complete?(fuel_type, target)

      calculate_monthly_consumption_between_target_dates(fuel_type, target)
    end

    def calculate_monthly_consumption_between_target_dates(fuel_type, target)
      start_date = target.start_date.beginning_of_month
      end_date = target.target_date.beginning_of_month.prev_day
      DateService.start_of_months(start_date, end_date).map do |date|
        previous_month = date - 1.year
        previous_consumption, previous_missing = calculate_month_consumption(previous_month, fuel_type)
        manual = if previous_missing
                   previous_consumption = @school.manual_readings.find_by(month: previous_month)&.[](fuel_type)
                   previous_missing = !previous_consumption.present?
                   previous_consumption.present?
                 else
                   false
                 end
        if !previous_missing || (manual && previous_consumption)
          target_consumption = apply_target_reduction(fuel_type, previous_consumption, target)
        end
        current_consumption, current_missing = calculate_month_consumption(date, fuel_type)
        month = [date.year, date.month, current_consumption, previous_consumption, target_consumption,
                 current_missing, previous_missing, manual]
        month
      end
    end

    def apply_target_reduction(fuel_type, value, target)
      reduction = value * (target[fuel_type] / 100.0)
      value - reduction
    end

    def calculate_month_consumption(month, fuel_type)
      kwhs = month.all_month.map do |date|
        @aggregated_school.aggregate_meter(fuel_type).amr_data[date]&.one_day_kwh
      end
      [kwhs.compact.empty? ? nil : kwhs.compact.sum, kwhs.include?(nil)]
    end

    def fuel_type_and_target?(fuel_type, target)
      fuel_type?(fuel_type) && target_for_fuel_type?(fuel_type, target)
    end

    def fuel_type?(fuel_type)
      @school.send(:"has_#{fuel_type}?")
    end

    def target_for_fuel_type?(fuel_type, target)
      return false if target.blank?

      target[fuel_type].present?
    end

    def target
      @school.most_recent_target
    end
  end
end

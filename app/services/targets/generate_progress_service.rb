# frozen_string_literal: true

module Targets
  class GenerateProgressService
    def initialize(school, aggregated_school)
      @school = school
      @aggregated_school = aggregated_school
      @progress_by_fuel_type = {}
      @reported_errors = {}
    end

    def cumulative_progress(fuel_type)
      target_progress = progress_report(fuel_type)
      target_progress.present? ? fetch_latest_figures(target_progress.cumulative_performance) : nil
    end

    def current_monthly_target(fuel_type)
      target_progress = progress_report(fuel_type)
      target_progress.present? ? fetch_latest_figures(target_progress.cumulative_targets_kwh) : nil
    end

    def current_monthly_usage(fuel_type)
      target_progress = progress_report(fuel_type)
      target_progress.present? ? fetch_latest_figures(target_progress.cumulative_usage_kwh) : nil
    end

    def generate!
      return unless Targets::SchoolTargetService.targets_enabled?(@school) && target.present?

      target.update!(
        electricity_progress: fuel_type_progress(:electricity),
        electricity_report: progress_report(:electricity),
        gas_progress: fuel_type_progress(:gas),
        gas_report: progress_report(:gas),
        storage_heaters_progress: fuel_type_progress(:storage_heaters),
        storage_heaters_report: progress_report(:storage_heaters),
        report_last_generated: Time.zone.now
      )
      @school.school_targets.find_each do |target|
        next if target_complete?(target)

        target.update!(
          electricity_monthly_consumption: calculate_monthly_consumption(:electricity, target),
          gas_monthly_consumption: calculate_monthly_consumption(:gas, target),
          storage_heaters_monthly_consumption: calculate_monthly_consumption(:storage_heaters, target)
        )
      end
      target
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
      return nil unless fuel_type_and_target?(fuel_type, target)

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

    def calculate_month_consumption(beginning_of_month, fuel_type)
      kwhs = (beginning_of_month..beginning_of_month.end_of_month).map do |date|
        @aggregated_school.aggregate_meter(fuel_type).amr_data[date]&.one_day_kwh
      end
      [kwhs.compact.empty? ? nil : kwhs.compact.sum, kwhs.include?(nil)]
    end

    def fuel_type_progress(fuel_type)
      if can_generate_fuel_type?(fuel_type)
        cumulative_progress = cumulative_progress(fuel_type)
        current_monthly_usage = current_monthly_usage(fuel_type)
        current_monthly_target = current_monthly_target(fuel_type)
        # if we encounted errors, the above values may be nil
        # in that case we can't produce a progress report for the fuel
        return {} if cumulative_progress.blank?

        Targets::FuelProgress.new(
          fuel_type: fuel_type,
          progress: cumulative_progress,
          usage: current_monthly_usage,
          target: current_monthly_target,
          recent_data: target_service(fuel_type).recent_data?
        )
      else
        {}
      end
    end

    def can_generate_fuel_type?(fuel_type)
      fuel_type_and_target?(fuel_type, target) && enough_data_to_calculate_target?(fuel_type)
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

    def fetch_latest_figures(hash_of_months_to_values)
      # sometimes the schools meter data may be lagging only a few days or a week
      # behind. this means that the progress report does not have data for this month,
      # it only has data for the previous month. So if there's no entry for the reporting
      # month, look for earlier data. This typically only happens around the beginning of
      # month when we're running a little behind on data
      hash_of_months_to_values[reporting_month] || hash_of_months_to_values[reporting_month.prev_month]
    end

    def reporting_month
      # if target is expired, then use the final month, otherwise report on
      # current progress
      if target.expired?
        target.target_date.prev_month.beginning_of_month
      else
        Time.zone.today.beginning_of_month
      end
    end

    def progress_report(fuel_type)
      return nil unless can_generate_fuel_type?(fuel_type)

      target_progress(fuel_type)
    end

    def target_progress(fuel_type)
      @progress_by_fuel_type[fuel_type] ||= target_service(fuel_type).progress
    rescue TargetDates::TargetDateBeforeFirstMeterStartDate
      nil
    rescue StandardError => e
      report_to_rollbar_once(e, fuel_type)
      nil
    end

    def enough_data_to_calculate_target?(fuel_type)
      return false unless target_service(fuel_type).enough_data_to_set_target?

      calculation_error = target_service(fuel_type).target_meter_calculation_problem
      raise StandardError, calculation_error[:text] if calculation_error.present?

      true
    rescue StandardError => e
      report_to_rollbar_once(e, fuel_type)
      false
    end

    def target_service(fuel_type)
      TargetsService.new(@aggregated_school, fuel_type)
    end

    # Report errors only once for each fuel type
    def report_to_rollbar_once(error, fuel_type)
      unless @reported_errors[fuel_type]
        Rollbar.error(error, scope: :generate_progress, school_id: @school.id, school: @school.name,
                             fuel_type: fuel_type)
      end
      @reported_errors[fuel_type] = true
    end
  end
end

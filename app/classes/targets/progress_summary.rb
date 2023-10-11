module Targets
  class ProgressSummary
    attr_reader :school_target, :electricity_progress, :gas_progress, :storage_heater_progress

    def initialize(school_target:, electricity:, gas:, storage_heater:)
      @school_target = school_target
      @electricity_progress = electricity
      @gas_progress = gas
      @storage_heater_progress = storage_heater
    end

    def any_progress?
      electricity_progress.present? || gas_progress.present? || storage_heater_progress.present?
    end

    def current_target?
      @school_target.current?
    end

    def out_of_date_fuel_types
      out_of_date = []
      out_of_date << :electricity if electricity_progress.present? && !electricity_progress.recent_data?
      out_of_date << :gas if gas_progress.present? && !gas_progress.recent_data?
      # treat storage heaters are electricity data when reporting to users
      out_of_date << :electricity if storage_heater_progress.present? && !storage_heater_progress.recent_data?
      out_of_date.uniq
    end

    def passing_fuel_targets(check_recent: true)
      passing = []
      passing << :electricity if passing?(electricity_progress, check_recent)
      passing << :gas if passing?(gas_progress, check_recent)
      passing << :storage_heater if passing?(storage_heater_progress, check_recent)
      passing
    end

    def failing_fuel_targets(check_recent: true)
      failed = []
      failed << :electricity if failing?(electricity_progress, check_recent)
      failed << :gas if failing?(gas_progress, check_recent)
      failed << :storage_heater if failing?(storage_heater_progress, check_recent)
      failed
    end

    def any_failing_targets?(check_recent: true)
      failing_fuel_targets(check_recent: check_recent).any?
    end

    def any_passing_targets?(check_recent: true)
      passing_fuel_targets(check_recent: check_recent).any?
    end

    def any_out_of_date_fuel_types?
      out_of_date_fuel_types.any?
    end

    private

    def passing?(fuel_progress, check_recent = true)
      return false unless fuel_progress.present? && fuel_progress.achieving_target?
      return true unless check_recent
      return true if fuel_progress.recent_data?

      false
    end

    def failing?(fuel_progress, check_recent = true)
      return false unless fuel_progress.present? && !fuel_progress.achieving_target?
      return true unless check_recent
      return true if fuel_progress.recent_data?

      false
    end
  end
end

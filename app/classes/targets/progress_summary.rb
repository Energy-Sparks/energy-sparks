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

    def failing_fuel_targets
      failed = []
      failed << :electricity if electricity_progress.present? && !electricity_progress.achieving_target?
      failed << :gas if gas_progress.present? && !gas_progress.achieving_target?
      failed << :storage_heater if storage_heater_progress.present? && !storage_heater_progress.achieving_target?
      failed
    end

    def failing_fuel_targets_as_sentence
      failing_fuel_targets.map { |s| s.to_s.humanize(capitalize: false) }.to_sentence
    end

    def any_failing_targets?
      failing_fuel_targets.any?
    end
  end
end

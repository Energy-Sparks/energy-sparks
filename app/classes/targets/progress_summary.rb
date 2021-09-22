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

    def out_of_date_fuel_types
      out_of_date = []
      out_of_date << :electricity if electricity_progress.present? && !electricity_progress.recent_data?
      out_of_date << :gas if gas_progress.present? && !gas_progress.recent_data?
      #treat storage heaters are electricity data when reporting to users
      out_of_date << :electricity if storage_heater_progress.present? && !storage_heater_progress.recent_data?
      out_of_date.uniq
    end

    def passing_fuel_targets
      passing = []
      passing << :electricity if electricity_progress.present? && electricity_progress.recent_data? && electricity_progress.achieving_target?
      passing << :gas if gas_progress.present? && gas_progress.recent_data? && gas_progress.achieving_target?
      passing << :storage_heater if storage_heater_progress.present? && storage_heater_progress.recent_data? && storage_heater_progress.achieving_target?
      passing
    end

    def failing_fuel_targets
      failed = []
      failed << :electricity if electricity_progress.present? && electricity_progress.recent_data? && !electricity_progress.achieving_target?
      failed << :gas if gas_progress.present? && gas_progress.recent_data? && !gas_progress.achieving_target?
      failed << :storage_heater if storage_heater_progress.present? && storage_heater_progress.recent_data? && !storage_heater_progress.achieving_target?
      failed
    end

    def out_of_date_fuel_types_as_sentence
      to_sentence(out_of_date_fuel_types)
    end

    def passing_fuel_targets_as_sentence
      to_sentence(passing_fuel_targets)
    end

    def failing_fuel_targets_as_sentence
      to_sentence(failing_fuel_targets)
    end

    def any_failing_targets?
      failing_fuel_targets.any?
    end

    def any_passing_targets?
      passing_fuel_targets.any?
    end

    def any_out_of_date_fuel_types?
      out_of_date_fuel_types.any?
    end

    private

    def to_sentence(list_of_fuel_types)
      list_of_fuel_types.map { |s| s.to_s.humanize(capitalize: false) }.to_sentence
    end
  end
end

module Targets
  class FuelProgress
    attr_reader :fuel_type, :progress, :usage, :target, :recent_data

    def initialize(fuel_type:, progress:, usage:, target:, recent_data: true)
      @fuel_type = fuel_type
      @progress = progress
      @usage = usage
      @target = target
      @recent_data = recent_data
    end

    def progress_formatted
      FormatEnergyUnit.format(:relative_percent, @progress, :html, false, true, :target) unless progress.nil?
    end

    def recent_data?
      @recent_data
    end

    def achieving_target?
      @progress.present? && @progress <= 0
    end
  end
end

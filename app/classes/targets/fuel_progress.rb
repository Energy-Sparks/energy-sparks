module Targets
  class FuelProgress
    attr_reader :fuel_type, :progress, :usage, :target

    def initialize(fuel_type:, progress:, usage:, target:)
      @fuel_type = fuel_type
      @progress = progress
      @usage = usage
      @target = target
    end

    def progress_formatted
      FormatEnergyUnit.format(:relative_percent, @progress, :html, false, true, :target) unless progress.nil?
    end

    def achieving_target?
      progress.present? && progress <= 0
    end
  end
end

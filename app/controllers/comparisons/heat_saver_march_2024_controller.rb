module Comparisons
  class HeatSaverMarch2024Controller < Shared::ArbitraryPeriodController
    private

    def key
      :heat_saver_march_2024
    end

    def load_data
      Comparison::HeatSaverMarch2024.for_schools(@schools).with_data_for_previous_period.by_total_percentage_change
    end
  end
end

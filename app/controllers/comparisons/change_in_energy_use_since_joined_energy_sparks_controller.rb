module Comparisons
  class ChangeInEnergyUseSinceJoinedEnergySparksController < Shared::ArbitraryPeriodController
    def key
      :change_in_energy_use_since_joined_energy_sparks
    end

    def load_data
      Comparison::ChangeInEnergyUseSinceJoinedEnergySparks.for_schools(@schools).with_data_for_previous_period.by_total_percentage_change
    end
  end
end

module Comparisons
  class ChangeInEnergyUseSinceJoinedEnergySparksController < Shared::ArbitraryPeriodController
    def key
      :change_in_energy_use_since_joined_energy_sparks
    end

    def set_headers
      super(include_previous_period_unadjusted: false)
    end

    # Fetch data for all schools where we can calculate a % change between last 12 months and
    # the 12 months prior to them having data activated on Energy Sparks.
    #
    # Order by total percentage change in kwh.
    #
    # When calculating totals only add up kwh consumption for fuel types with data in both
    # periods.
    def load_data
      Comparison::ChangeInEnergyUseSinceJoinedEnergySparks.for_schools(@schools).with_reportable_data.by_total_percentage_change
    end
  end
end

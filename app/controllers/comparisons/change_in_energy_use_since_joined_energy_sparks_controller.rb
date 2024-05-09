module Comparisons
  class ChangeInEnergyUseSinceJoinedEnergySparksController < Shared::ArbitraryPeriodController
    def key
      :change_in_energy_use_since_joined_energy_sparks
    end

    def set_headers
      @colgroups = colgroups
      @headers = headers
      @include_previous_period_unadjusted = false
      @electricity_colgroups = colgroups(fuel: false)
      @electricity_headers = headers(fuel: false)
      @heating_colgroups = colgroups(fuel: false, previous_period_unadjusted: @include_previous_period_unadjusted)
      @heating_headers = headers(fuel: false, previous_period_unadjusted: @include_previous_period_unadjusted)
      @period_type_string = I18n.t('comparisons.period_types.periods')
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

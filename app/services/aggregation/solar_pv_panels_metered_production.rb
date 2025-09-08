# frozen_string_literal: true

module Aggregation
  # Subclass used where we have metered generation data, but no export or
  # self-consumption. Just ensures that the generation data is padded out
  # to match the mains meter and treats entire date range as needing
  # synthetic data
  #
  # called where metered generation meter but no export or self consumption
  class SolarPvPanelsMeteredProduction < SolarPvPanels
    def initialize
      super(nil, nil)
      @real_production_data = true
    end

    private

    def create_generation_amr_data(mains_amr_data, pv_amr_data, mpan, _create_zero_if_no_config)
      mains_amr_data.date_range.each do |date|
        next if pv_amr_data.date_exists?(date)

        # pad out generation data to that of mains electric meter
        # so downstream analysis doesn't need to continually test
        # for its existence
        pv_amr_data.add(date, OneDayAMRReading.zero_reading(mpan, date, 'SOL0'))
      end
    end

    def synthetic_data?(_date, _type)
      true
    end
  end
end

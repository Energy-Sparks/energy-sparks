# frozen_string_literal: true

require 'rails_helper'

describe AnalyseHeatingAndHotWater::HeatingNonHeatingDisaggregationWithRegressionCOVIDTolerantModel do
  describe '#max_non_heating_day_kwh' do
    it 'produces not default figure' do
      start_date = Date.new(2023, 5, 1) # needs to include months 6, 7, 8
      end_date = Date.new(2023, 7, 1)
      meter = build(:meter, :with_flat_rate_tariffs,
                    type: :gas,
                    meter_collection: build(
                      :meter_collection, start_date: start_date, end_date: end_date,
                                         temperatures: build(
                                           :temperatures, :with_days, start_date: start_date, end_date: end_date,
                                                                      kwh_data_x48: Array.new(48, 10.1)
                                         )
                    ),
                    amr_data: build(:amr_data, :with_date_range,
                                    type: :gas, start_date: start_date, end_date: end_date,
                                    # if the daily kwh is less than 20kwh (@max_zero_daily_kwh) the regression is
                                    # skipped
                                    # certain values like 0.5, 1 cause the regression r2 to be NaN which also break it
                                    # (perhaps float represention related)
                                    kwh_data_x48: Array.new(48, 0.8)))
      model = described_class.new(meter, {})
      model.calculate_max_summer_hotwater_kitchen_kwh(SchoolDatePeriod.new(nil, nil, start_date, end_date))
      expect(model.max_non_heating_day_kwh(start_date)).to be_within(0.01).of(38.4)
    end
  end
end

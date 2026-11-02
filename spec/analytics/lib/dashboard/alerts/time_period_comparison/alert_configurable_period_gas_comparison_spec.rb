# frozen_string_literal: true

require 'rails_helper'
require_relative 'configurable_period_comparison_shared'

describe AlertConfigurablePeriodGasComparison, :aggregate_failures do
  let(:meter_collection) do
    school = build(:analytics_school)
    build(:meter_collection, :with_aggregated_aggregate_meter,
          start_date: Date.new(2022, 11, 1), end_date: Date.new(2023, 11, 30),
          fuel_type: :gas, random_generator: Random.new(22), school:,
          pseudo_meter_attributes: { school_level_data: {
            floor_area_pupil_numbers: [{ start_date: Date.new(2023, 11, 17),
                                         end_date: Date.new(2023, 11, 17),
                                         floor_area: school.floor_area / 2 }]
          } })
  end

  it_behaves_like 'a configurable period comparison', current_period_kwh: 48, previous_period_kwh: 96 do
    describe '#analyse' do
      it 'can disable normalisation' do
        configuration[:disable_normalisation] = true
        alert.analyse(analysis_date)
        expect(alert.previous_period_kwh).to be_within(0.01).of(48)
        expect(alert.current_period_kwh).to be_within(0.01).of(48)
      end
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

describe AnalyseHeatingAndHotWater::ModelCache do
  subject(:heat_model) { meter_collection.aggregated_heat_meters.heating_model }

  let(:meter_collection) do
    temperatures = build(:temperatures, :with_summer_and_winter, start_date: Date.new(2023, 1, 1),
                                                                 end_date: Date.new(2023, 12, 31))

    meter_collection = build(:meter_collection,
                             holidays: build(:holidays, :with_calendar_year, year: 2023),
                             temperatures: temperatures,
                             start_date: Date.new(2023, 1, 1),
                             end_date: Date.new(2023, 12, 31))

    amr_data = build(:amr_data, :with_summer_and_winter_usage,
                     type: :gas,
                     start_date: Date.new(2023, 1, 1),
                     end_date: Date.new(2023, 12, 31))

    meter = build(:meter, :with_flat_rate_tariffs,
                  meter_collection: meter_collection,
                  type: :gas,
                  amr_data: amr_data)
    meter_collection.add_heat_meter(meter)
    AggregateDataService.new(meter_collection).aggregate_heat_and_electricity_meters

    meter_collection
  end

  it 'caches generated models' do
    # regenerating the model should return same instance
    expect(heat_model).to eq(meter_collection.aggregated_heat_meters.heating_model)
    meter_collection.aggregated_heat_meters.model_cache.clear_model_cache
    expect(heat_model.object_id).not_to eq(meter_collection.aggregated_heat_meters.heating_model.object_id)
  end
end

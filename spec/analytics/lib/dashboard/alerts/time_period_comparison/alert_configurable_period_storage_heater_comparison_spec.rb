# frozen_string_literal: true

require 'rails_helper'
require_relative 'configurable_period_comparison_shared'

describe AlertConfigurablePeriodStorageHeaterComparison do
  let(:meter_collection) do
    build(:meter_collection, :with_aggregated_aggregate_meter,
          start_date: Date.new(2022, 11, 1), end_date: Date.new(2023, 11, 30),
          storage_heaters: true, random_generator: Random.new(30))
  end

  it_behaves_like 'a configurable period comparison', current_period_kwh: 27, previous_period_kwh: 27
end

# frozen_string_literal: true

require 'rails_helper'

describe AnalyseHeatingAndHotWater::HeatingModelTemperatureSpace do
  # testing private method directly not ideal, but makes it easier to
  # test variety of options, pending further refactoring of the heating model
  # code
  describe '#recommended_optimum_start_time' do
    let(:meter) { build(:meter, type: :gas) }
    let(:model_overrides) { {} }

    let(:heating_model) { AnalyseHeatingAndHotWater::HeatingModelTemperatureSpace.new(meter, model_overrides) }

    it 'returns expected half-hourly values' do
      expect(heating_model.send(:recommended_optimum_start_time, nil, 3.0)).to eq [TimeOfDay.new(0, 0), 0]
      expect(heating_model.send(:recommended_optimum_start_time, nil, 4.0)).to eq [TimeOfDay.new(3, 30), 7]
      expect(heating_model.send(:recommended_optimum_start_time, nil, 10.0)).to eq [TimeOfDay.new(6, 30), 13]

      expect(heating_model.send(:recommended_optimum_start_time, nil, 4.9)).to eq [TimeOfDay.new(3, 30), 7]
      expect(heating_model.send(:recommended_optimum_start_time, nil, 7.1)).to eq [TimeOfDay.new(5, 0), 10]
    end
  end
end

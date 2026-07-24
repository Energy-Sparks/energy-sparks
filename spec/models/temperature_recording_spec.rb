require 'rails_helper'

describe TemperatureRecording do
  let(:location)       { build(:location) }
  let(:observation)    { build(:observation, :temperature) }

  it 'can have a temperature in the range 0 to 50' do
    expect do
      TemperatureRecording.create(centigrade: 20, location: location,
                                  observation: observation)
    end.to change(TemperatureRecording, :count).by(1)
  end

  it 'cannot have a temperature in the range -5' do
    expect do
      TemperatureRecording.create(centigrade: -5, location: location,
                                  observation: observation)
    end.not_to change(TemperatureRecording, :count)
  end

  it 'cannot have a temperature in the range 60' do
    expect do
      TemperatureRecording.create(centigrade: 60, location: location,
                                  observation: observation)
    end.not_to change(TemperatureRecording, :count)
  end
end

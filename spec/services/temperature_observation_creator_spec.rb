require 'rails_helper'

describe TemperatureObservationCreator do
  it 'saves the observation' do
    observation = build(:observation)
    TemperatureObservationCreator.new(observation).process
    expect(observation).to be_persisted
  end

  it 'sets the observation type to :temperature' do
    observation = build(:observation, observation_type: nil)
    TemperatureObservationCreator.new(observation).process
    expect(observation.observation_type).to eq("temperature")
  end

  it 'creates an observation with 5 points' do
    observation = build(:observation)
    TemperatureObservationCreator.new(observation).process
    expect(observation.points).to eq(5)
  end

  it 'scores 0 points for previous academic years' do
    observation = build(:observation, at: 3.years.ago)
    TemperatureObservationCreator.new(observation).process
    expect(observation.points).to eq(nil)
  end

  it 'scores 0 points if there is already an observation on that day' do
    school = create(:school)
    observation_1 = build(:observation, school: school)
    TemperatureObservationCreator.new(observation_1).process
    observation_2 = build(:observation, school: school)
    TemperatureObservationCreator.new(observation_2).process
    expect(observation_1.points).to eq(5)
    expect(observation_2.points).to eq(nil)
  end
end

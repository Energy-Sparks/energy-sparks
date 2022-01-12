require 'rails_helper'

describe InterventionCreator do

  let(:intervention_type){ create(:intervention_type, points: 50) }

  it 'saves the observation' do
    observation = build(:observation, intervention_type: intervention_type)
    InterventionCreator.new(observation).process
    expect(observation).to be_persisted
  end

  it 'sets the observation type to :intervention' do
    observation = build(:observation, intervention_type: intervention_type, observation_type: nil)
    InterventionCreator.new(observation).process
    expect(observation.observation_type).to eq("intervention")
  end

  it 'creates an observation with the number of points from the type' do
    observation = build(:observation, intervention_type: intervention_type)
    InterventionCreator.new(observation).process
    expect(observation.points).to eq(50)
  end

  it 'scores 0 points for previous academic years' do
    observation = build(:observation, intervention_type: intervention_type, at: 3.years.ago)
    InterventionCreator.new(observation).process
    expect(observation.points).to eq(nil)
  end

  context 'with an audit' do
    it 'marks an action as complete'
  end
end

require 'rails_helper'

describe InterventionCreator do

  let(:intervention_type){ create(:intervention_type, score: 50) }

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

  it 'creates an observation with a score if pupils involved' do
    observation = build(:observation, intervention_type: intervention_type, involved_pupils: true)
    InterventionCreator.new(observation).process
    expect(observation.points).to eq(50)
  end

  it 'creates an observation with no score if pupils not involved' do
    observation = build(:observation, intervention_type: intervention_type, involved_pupils: false)
    InterventionCreator.new(observation).process
    expect(observation.points).to eq(nil)
  end

  it 'scores 0 points for previous academic years' do
    observation = build(:observation, intervention_type: intervention_type, at: 3.years.ago, involved_pupils: true)
    InterventionCreator.new(observation).process
    expect(observation.points).to eq(nil)

    observation = build(:observation, intervention_type: intervention_type, at: 3.years.ago, involved_pupils: false)
    InterventionCreator.new(observation).process
    expect(observation.points).to eq(nil)
  end
end

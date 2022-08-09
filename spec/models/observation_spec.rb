require 'rails_helper'

describe Observation do

  let(:school_name) { 'Active school'}
  let!(:school)     { create(:school, name: school_name) }

  it 'can have a date in the past' do
    expect(Observation.new(at: Date.yesterday, school: school).valid?).to be true
  end

  it 'can have a date today' do
    expect(Observation.new(at: DateTime.now, school: school).valid?).to be true
  end

  it 'cannot have a date in the future' do
    expect(Observation.new(at: Date.tomorrow, school: school).valid?).to be false
  end

  context 'interventions' do
    let!(:intervention_type){ create(:intervention_type, score: 50) }

    it 'only adds points automatically if its an intervention' do
      observation = build(:observation, observation_type: :temperature, involved_pupils: true)
      observation.save
      expect(observation.points).to eq(nil)
    end

    it 'sets the score if pupils involved' do
      observation = build(:observation, observation_type: :intervention, intervention_type: intervention_type, involved_pupils: true)
      observation.save
      expect(observation.points).to eq(50)
    end

    it 'does not set score if pupils not involved' do
      observation = build(:observation, observation_type: :intervention, intervention_type: intervention_type, involved_pupils: false)
      observation.save
      expect(observation.points).to eq(nil)
    end

    it 'scores 0 points for previous academic years' do
      observation = build(:observation, observation_type: :intervention, intervention_type: intervention_type, at: 3.years.ago, involved_pupils: true)
      observation.save
      expect(observation.points).to eq(nil)

      observation = build(:observation, observation_type: :intervention, intervention_type: intervention_type, at: 3.years.ago, involved_pupils: false)
      observation.save
      expect(observation.points).to eq(nil)
    end

    it 'updates score if date changed' do
      observation = build(:observation, observation_type: :intervention, intervention_type: intervention_type, at: 3.years.ago, involved_pupils: true)
      observation.save!
      expect(observation.points).to eq(nil)
      expect(observation.intervention?).to be true
      observation.update(observation_type: :intervention, at: Date.today)
      observation.reload
      expect(observation.points).to eq(50)
    end

  end
end

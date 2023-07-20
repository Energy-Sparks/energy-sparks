require 'rails_helper'

describe Observation do

  let(:school_name) { 'Active school'}
  let!(:school)     { create(:school, name: school_name) }

  describe '#pupil_count' do
    it "is valid when present for interventions only" do
      expect(build(:observation, observation_type: :temperature, pupil_count: 12)).to be_invalid
      expect(build(:observation, observation_type: :event, pupil_count: 12)).to be_invalid
      expect(build(:observation, observation_type: :activity, activity: create(:activity), pupil_count: 12)).to be_invalid
      expect(build(:observation, observation_type: :audit, audit: create(:audit), pupil_count: 12)).to be_invalid
      expect(build(:observation, observation_type: :school_target, school_target: create(:school_target), pupil_count: 12)).to be_invalid

      expect(build(:observation, observation_type: :intervention, intervention_type: create(:intervention_type), pupil_count: 12)).to be_valid
    end
  end

  describe '#recorded_in_last_week' do
    let(:observation_too_old)      { create(:observation, observation_type: :temperature) }
    let(:observation_last_week_1)  { create(:observation, observation_type: :temperature) }
    let(:observation_last_week_2)  { create(:observation, observation_type: :temperature) }

    before :each do
      observation_too_old.update!(created_at: (7.days.ago - 1.minute))
      observation_last_week_1.update!(created_at: (7.days.ago + 1.minute))
      observation_last_week_2.update!(created_at: 1.minute.ago)
    end

    it 'should exclude older observations' do
      expect( Observation.recorded_in_last_week ).to match_array([observation_last_week_1, observation_last_week_2])
    end
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

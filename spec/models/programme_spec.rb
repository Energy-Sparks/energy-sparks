require 'rails_helper'

describe 'Programme' do
  let(:school) { create :school }
  let(:programme_type) { create(:programme_type, bonus_score: 12) }

  let(:programme) { Programme.create!(programme_type: programme_type, started_on: '2020-01-01', school: school) }

  before { Observation.delete_all }

  describe '#complete' do
    it 'completes a program and creates an observation as it is completed within the same academic year as they started it' do
      allow_any_instance_of(School).to receive(:academic_year_for) { OpenStruct.new(current?: true) }
      expect(Observation.count).to eq(0)
      expect(programme.completed?).to be_falsey
      expect(programme.ended_on).to be_nil
      programme.complete!
      expect(programme.completed?).to be_truthy
      expect(programme.ended_on).not_to be_nil
      expect(Observation.count).to eq(1)
      expect(Observation.last.points).to eq(12)
    end

    it 'completes a program and creates an observation but does not add bonus points as it is completed outside of the academic year when they started it' do
      allow_any_instance_of(School).to receive(:academic_year_for) { OpenStruct.new(current?: false) }
      expect(Observation.count).to eq(0)
      expect(programme.completed?).to be_falsey
      expect(programme.ended_on).to be_nil
      programme.complete!
      expect(programme.completed?).to be_truthy
      expect(programme.ended_on).not_to be_nil
      expect(Observation.count).to eq(1)
      expect(Observation.last.points).to eq(0)
    end
  end

  it '#abandon' do
    expect(programme.abandoned?).to be_falsy
    expect(programme.ended_on).to be_nil
    programme.abandon!
    expect(programme.abandoned?).to be_truthy
    expect(programme.ended_on).to be_nil
  end
end

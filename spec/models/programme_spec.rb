require 'rails_helper'

describe 'Programme' do

  let(:school) { create :school }
  let(:programme_type) { create(:programme_type, bonus_score: 12) }

  let(:programme) { Programme.create!(programme_type: programme_type, started_on: '2020-01-01', school: school) }

  before { Observation.delete_all }

  it '#complete' do
    expect(Observation.count).to eq(0)
    expect(programme.completed?).to be_falsey
    expect(programme.ended_on).to be_nil

    programme.complete!

    expect(programme.completed?).to be_truthy
    expect(programme.ended_on).not_to be_nil
    expect(Observation.count).to eq(1)
    expect(Observation.last.points).to eq(12)
  end

  it '#abandon' do
    expect(Observation.count).to eq(0)
    expect(programme.abandoned?).to be_falsy
    expect(programme.ended_on).to be_nil

    programme.abandon!

    expect(Observation.count).to eq(0)
    expect(programme.abandoned?).to be_truthy
    expect(programme.ended_on).to be_nil
  end
end

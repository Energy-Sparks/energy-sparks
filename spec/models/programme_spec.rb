require 'rails_helper'

describe 'Programme' do

  let(:school) { create :school }
  let(:programme_type) { create :programme_type }

  let(:programme) { Programme.create!(programme_type: programme_type, started_on: '2020-01-01', school: school) }

  it '#complete' do
    programme.complete!
    expect( programme.completed? ).to be_truthy
    expect( programme.ended_on ).not_to be_nil
  end

  it '#abandon' do
    programme.abandon!
    expect( programme.abandoned? ).to be_truthy
    expect( programme.ended_on ).to be_nil
  end
end

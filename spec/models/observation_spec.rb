require 'rails_helper'

describe Observation do

  let(:school_name) { 'Active school'}
  let!(:school)     { create(:school, name: school_name) }

  it 'can have a date in the past' do
   expect { Observation.create(at: Date.yesterday, school: school ) }.to change { Observation.count }.by(1)
  end

  it 'can have a date today' do
   expect { Observation.create(at: DateTime.now, school: school ) }.to change { Observation.count }.by(1)
  end

  it 'cannot have a date in the future' do
    expect { Observation.create(at: Date.tomorrow, school: school) }.to change { Observation.count }.by(0)
  end


end
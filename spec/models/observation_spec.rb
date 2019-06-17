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
end
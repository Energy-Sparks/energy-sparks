require 'rails_helper'

describe 'ActivityType' do

  subject { create :activity_type }

  it 'is valid with valid attributes' do
    expect(subject).to be_valid
  end

  it 'is invalid with invalid attributes' do
    type = build :activity_type, score: -1
    expect( type ).to_not be_valid
    expect( type.errors[:score] ).to include('must be greater than or equal to 0')
  end
end
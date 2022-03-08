require 'rails_helper'

describe 'TransportType' do

  subject { create :transport_type }

  it 'is valid with valid attributes' do
    expect(subject).to be_valid
  end
end
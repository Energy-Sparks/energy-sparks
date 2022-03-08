require 'rails_helper'

describe 'TransportSurvey' do

  subject { create :transport_survey }

  it 'is valid with valid attributes' do
    expect(subject).to be_valid
  end

end

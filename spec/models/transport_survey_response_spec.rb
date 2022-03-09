require 'rails_helper'

describe 'TransportSurveyResponse' do

  subject { create :transport_survey_response }

  it 'is valid with valid attributes' do
    expect(subject).to be_valid
  end

end

require 'rails_helper'

describe 'TransportSurveyResponse' do

  context "with valid attributes" do
    subject { create :transport_survey_response }
    it { is_expected.to be_valid }
  end

  describe '#weather_symbol' do
    subject(:response) { build :transport_survey_response, weather: :sun }

    it 'returns a weather symbol' do
      expect(response.weather_symbol).to eq("☀️")
    end
  end

end

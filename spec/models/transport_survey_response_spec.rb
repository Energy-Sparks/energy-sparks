require 'rails_helper'

describe TransportSurveyResponse do

  describe 'validations' do
    subject { build(:transport_survey_response) }

    it { is_expected.to be_valid }
    [:transport_survey_id, :transport_type_id, :passengers, :run_identifier, :surveyed_at, :journey_minutes, :weather].each do |attribute|
      it { is_expected.to validate_presence_of(attribute) }
    end
    it { is_expected.to validate_inclusion_of(:journey_minutes).in_array(TransportSurveyResponse.journey_minutes_options) }
    it { is_expected.to validate_inclusion_of(:passengers).in_array(TransportSurveyResponse.passengers_options)}
  end

  describe 'enums' do
    it { should define_enum_for(:weather).with_values([:sun, :cloud, :rain, :snow]) }
  end

  describe '#weather_symbol' do
    TransportSurveyResponse.weather_symbols.each do |key, value|
      context "for #{key}" do
        subject(:response) { create :transport_survey_response, weather: key }
        it { expect(response.weather_symbol).to eq(value) }
      end
    end
  end

  describe "#carbon" do
    pending "being written"
  end

  describe "#carbon_per_passenger" do
    pending "being written"
  end

end

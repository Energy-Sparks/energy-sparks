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

  describe "carbon calcs" do
    let(:carbon_calc) { ((transport_type.speed_km_per_hour * response.journey_minutes) / 60) * transport_type.kg_co2e_per_km }

    describe "#carbon" do
      let(:transport_type) { create :transport_type, can_share: can_share, park_and_stride: park_and_stride }

      context "when transport type is not park and stride" do
        let(:park_and_stride) { false }
        let(:response) { create :transport_survey_response, transport_type: transport_type, passengers: 3, journey_minutes: 5 }

        context "when carbon can be shared across group" do
          let(:can_share) { true }
          it "calculates the total carbon per response" do
            expect(response.carbon).to eq(carbon_calc)
          end
        end
        context "when carbon can't be shared" do
          let(:can_share) { false }
          it "multiplies the response carbon by the amount of passengers" do
            expect(response.carbon).to eq(carbon_calc * response.passengers)
          end
        end
      end

      context "when transport type uses park and stride" do
        let(:park_and_stride) { true }
        let(:can_share) { true }
        let(:carbon_calc_ps) { ((transport_type.speed_km_per_hour * (response.journey_minutes - 15)) / 60) * transport_type.kg_co2e_per_km }

        context "for journeys 15 minutes and under" do
          let(:response) { create :transport_survey_response, transport_type: transport_type, passengers: 3, journey_minutes: 15 }
          it { expect(response.carbon).to eq(0) }
        end
        context "for journeys over 15 mins" do
          let(:response) { create :transport_survey_response, transport_type: transport_type, passengers: 3, journey_minutes: 20 }
          it "calculates the carbon with 15 less minutes" do
            expect(response.carbon).to eq(carbon_calc_ps)
          end
        end
      end
    end

    describe "#carbon_per_passenger" do
      let(:transport_type) { create :transport_type, can_share: can_share, park_and_stride: false }
      let(:response) { create :transport_survey_response, transport_type: transport_type, passengers: 3, journey_minutes: 15 }

      context "when carbon can be shared across group" do
        let(:can_share) { true }
        it "divides the carbon between the passengers" do
          expect(response.carbon_per_passenger).to eq(carbon_calc / response.passengers)
        end
      end
      context "when carbon cannot be shared" do
        let(:can_share) { false }
        it "returns the full amount per passenger" do
          expect(response.carbon_per_passenger).to eq(carbon_calc)
        end
      end
    end
  end
end

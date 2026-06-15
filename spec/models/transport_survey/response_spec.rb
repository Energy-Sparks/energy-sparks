require 'rails_helper'

describe TransportSurvey::Response do
  describe 'validations' do
    subject { build(:transport_survey_response) }

    it { is_expected.to be_valid }

    [:transport_survey_id, :transport_type_id, :passengers, :run_identifier, :surveyed_at, :journey_minutes, :weather].each do |attribute|
      it { is_expected.to validate_presence_of(attribute) }
    end
    it { is_expected.to validate_inclusion_of(:journey_minutes).in_array(TransportSurvey::Response.journey_minutes_options) }
    it { is_expected.to validate_inclusion_of(:passengers).in_array(TransportSurvey::Response.passengers_options)}
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:weather).with_values([:sun, :cloud, :rain, :snow]) }
  end

  describe '#weather_image' do
    TransportSurvey::Response.weather_images.each do |key, value|
      context "when key is: #{key}" do
        subject(:response) { create :transport_survey_response, weather: key }

        it { expect(response.weather_image).to eq(value) }
      end
    end
  end

  describe '#carbon' do
    let(:transport_type) { create :transport_type, can_share: can_share, park_and_stride: park_and_stride }
    let(:carbon_calc) { ((transport_type.speed_km_per_hour * response.journey_minutes) / 60) * transport_type.kg_co2e_per_km }

    context 'when transport type is not park and stride' do
      let(:park_and_stride) { false }
      let(:response) { create :transport_survey_response, transport_type: transport_type, passengers: 3, journey_minutes: 15 }

      context 'when carbon can be shared across group' do
        let(:can_share) { true }

        it 'divides the carbon between the passengers' do
          expect(response.carbon).to eq(carbon_calc / response.passengers)
        end
      end

      context 'when carbon cannot be shared' do
        let(:can_share) { false }

        it 'returns the full amount per passenger' do
          expect(response.carbon).to eq(carbon_calc)
        end
      end
    end

    context 'when transport type uses park and stride' do
      let(:park_and_stride) { true }
      let(:can_share) { false }
      let(:carbon_calc_ps) { ((transport_type.speed_km_per_hour * (response.journey_minutes - TransportSurvey::Response.park_and_stride_mins)) / 60) * transport_type.kg_co2e_per_km }

      context "when journeys are #{TransportSurvey::Response.park_and_stride_mins} minutes and under" do
        let(:response) { create :transport_survey_response, transport_type: transport_type, passengers: 3, journey_minutes: TransportSurvey::Response.park_and_stride_mins }

        it { expect(response.carbon).to eq(0) }
      end

      context "when journeys are over #{TransportSurvey::Response.park_and_stride_mins} mins" do
        let(:response) { create :transport_survey_response, transport_type: transport_type, passengers: 3, journey_minutes: TransportSurvey::Response.park_and_stride_mins + 5 }

        it "calculates the carbon with #{TransportSurvey::Response.park_and_stride_mins} less minutes" do
          expect(response.carbon).to eq(carbon_calc_ps)
        end
      end
    end
  end

  describe '.to_csv' do
    let(:transport_survey) { create(:transport_survey) }
    subject(:csv) { transport_survey.responses.to_csv }

    let(:header) { 'Id,Run identifier,Weather,Journey minutes,Transport type name,Passengers,Carbon kg co2,Surveyed at' }

    context 'with responses' do
      let!(:responses) { create_list(:transport_survey_response, 2, transport_survey: transport_survey) }

      it { expect(csv.lines.count).to eq(3) }
      it { expect(csv.lines.first.chomp).to eq(header) }

      2.times do |i|
        it { expect(csv.lines[i + 1].chomp).to eq([responses[i].id, responses[i].run_identifier, responses[i].weather_name, responses[i].journey_minutes, responses[i].transport_type.name, responses[i].passengers, responses[i].carbon_kg_co2, responses[i].surveyed_at].join(',')) }
      end
    end

    context 'with responses for other schools' do
      let!(:responses) { create_list(:transport_survey_response, 2) }

      it { expect(csv.lines.count).to eq(1) }
    end

    context 'with no responses' do
      it { expect(csv.lines.count).to eq(1) }
      it { expect(csv.lines.first.chomp).to eq(header) }
    end
  end
end

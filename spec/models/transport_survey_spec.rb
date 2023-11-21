require 'rails_helper'

describe 'TransportSurvey' do
  context "with valid attributes" do
    subject(:transport_survey) { create :transport_survey }

    it { is_expected.to be_valid }
  end

  describe "#responses=" do
    subject(:transport_survey) { create :transport_survey }

    describe "adding a response" do
      let(:attributes) { attributes_for(:transport_survey_response, surveyed_at: surveyed_at, run_identifier: run_identifier) }
      let(:surveyed_at) { DateTime.new(2021, 0o3, 18, 9, 0, 0) }
      let(:run_identifier) { 1234 }

      before { transport_survey.responses = [attributes] }

      it { expect(transport_survey.responses.length).to eql 1 }

      describe "adding another response" do
        let(:new_attributes) { attributes_for(:transport_survey_response, surveyed_at: new_surveyed_at, run_identifier: new_run_identifier) }

        before { transport_survey.responses = [new_attributes] }

        context "with the same run_identifier" do
          let(:new_run_identifier) { run_identifier }

          context "and the same surveyed_at time" do
            let(:new_surveyed_at) { surveyed_at }

            it { expect(transport_survey.responses.length).to eql 1 }
          end

          context "and different surveyed_at time" do
            let(:new_surveyed_at) { DateTime.new(2022, 0o3, 18, 9, 0, 0) }

            it { expect(transport_survey.responses.length).to eql 2 }
          end
        end

        context "with a different run_identifier" do
          let(:new_run_identifier) { 9999 }

          context "and the same surveyed_at time" do
            let(:new_surveyed_at) { surveyed_at }

            it { expect(transport_survey.responses.length).to eql 2 }
          end

          context "and a different surveyed_at time" do
            let(:new_surveyed_at) { DateTime.new(2022, 0o3, 18, 9, 0, 0) }

            it { expect(transport_survey.responses.length).to eql 2 }
          end
        end
      end
    end
  end

  describe "#total_responses" do
    subject(:transport_survey) { create :transport_survey }

    context "with no responses" do
      it { expect(transport_survey.total_responses).to eql 0 }
    end

    context "with one response" do
      before do
        create :transport_survey_response, transport_survey: transport_survey, passengers: 2
      end

      it { expect(transport_survey.total_responses).to eql 1 }
    end

    context "with more than one response" do
      before do
        create :transport_survey_response, transport_survey: transport_survey, passengers: 2
        create :transport_survey_response, transport_survey: transport_survey, passengers: 3
      end

      it { expect(transport_survey.total_responses).to eql 2 }
    end
  end

  describe "#total_carbon" do
    subject(:transport_survey) { create :transport_survey }

    context "with no responses" do
      it { expect(transport_survey.total_carbon).to eql 0 }
    end

    context "with one response" do
      let!(:response) { create(:transport_survey_response, transport_survey: transport_survey, passengers: 2) }

      it { expect(transport_survey.total_carbon).to eql response.carbon }
    end

    context "with more than one response" do
      let!(:responses) do
        [create(:transport_survey_response, transport_survey: transport_survey, passengers: 2),
         create(:transport_survey_response, transport_survey: transport_survey, passengers: 3)]
      end

      it "adds up the carbon for each response" do
        expect(transport_survey.total_carbon).to eql(responses[0].carbon + responses[1].carbon)
      end
    end
  end

  describe "Category based methods" do
    subject(:transport_survey) { create :transport_survey }

    let(:categories) { TransportSurvey::TransportType.categories.keys << nil }

    def create_responses(cats)
      cats.each do |cat|
        transport_type = create(:transport_type, category: cat)
        create(:transport_survey_response, transport_survey: transport_survey, transport_type: transport_type, passengers: 3)
      end
    end

    describe "#responses_per_category" do
      context "when there are responses in each category" do
        before { create_responses(categories) }

        it "returns a hash of responses per category" do
          expect(transport_survey.responses_per_category).to eql({ "car" => 1, "walking_and_cycling" => 1, "public_transport" => 1, "park_and_stride" => 1, "other" => 1 })
        end
      end

      context "when not all categories have responses" do
        before { create_responses(categories.excluding('car', 'walking_and_cycling')) }

        it "returns a hash with zero values for missing categories" do
          expect(transport_survey.responses_per_category).to eql({ "car" => 0, "walking_and_cycling" => 0, "public_transport" => 1, "park_and_stride" => 1, "other" => 1 })
        end

        context "and categories have multiple responses" do
          before { create_responses(categories) }

          it "adds them up" do
            expect(transport_survey.responses_per_category).to eql({ "car" => 1, "walking_and_cycling" => 1, "public_transport" => 2, "park_and_stride" => 2, "other" => 2 })
          end
        end
      end

      context "when there are no responses" do
        it "returns a hash with zero values for missing categories" do
          expect(transport_survey.responses_per_category).to eql({ "car" => 0, "walking_and_cycling" => 0, "public_transport" => 0, "park_and_stride" => 0, "other" => 0 })
        end
      end
    end

    describe "#percentage_per_category" do
      context "when there are responses in each category" do
        before { create_responses(categories) }

        it "returns a hash of responses percentages per category" do
          expect(transport_survey.percentage_per_category).to eql({ "car" => 20.0, "walking_and_cycling" => 20.0, "public_transport" => 20.0, "park_and_stride" => 20.0, "other" => 20.0 })
        end
      end

      context "when not all categories have responses" do
        before { create_responses(categories.excluding('car', 'park_and_stride', nil)) }

        it "returns zero values for missing categories" do
          expect(transport_survey.percentage_per_category).to eql({ "car" => 0, "walking_and_cycling" => 50.0, "public_transport" => 50.0, "park_and_stride" => 0, "other" => 0 })
        end

        context "and categories have multiple responses" do
          before { create_responses(categories) }

          it "adds them up" do
            expect(transport_survey.percentage_per_category).to eql({ "car" => 14.285714285714285, "walking_and_cycling" => 28.57142857142857, "public_transport" => 28.57142857142857, "park_and_stride" => 14.285714285714285, "other" => 14.285714285714285 })
          end
        end
      end

      context "when there are no responses" do
        it "returns zero values for missing categories" do
          expect(transport_survey.percentage_per_category).to eql({ "car" => 0, "walking_and_cycling" => 0, "public_transport" => 0, "park_and_stride" => 0, "other" => 0 })
        end
      end
    end

    describe "#pie_chart_data" do
      context "when there are passengers in each category" do
        before { create_responses(categories) }

        it "returns passenger percentages per category" do
          expect(transport_survey.pie_chart_data).to eql([{ name: "Walking and cycling", y: 20.0 }, { name: "Car", y: 20.0 }, { name: "Public transport", y: 20.0 }, { name: "Park and stride", y: 20.0 }, { name: "Other", y: 20.0 }])
        end
      end

      context "when not all categories have passengers" do
        before { create_responses(categories.excluding('car', 'park_and_stride', nil)) }

        it "returns zero values for missing categories" do
          expect(transport_survey.pie_chart_data).to eql([{ name: "Walking and cycling", y: 50.0 }, { name: "Car", y: 0 }, { name: "Public transport", y: 50.0 }, { name: "Park and stride", y: 0 }, { name: "Other", y: 0 }])
        end
      end

      context "when there are no responses" do
        it "returns zero values for missing categories" do
          expect(transport_survey.pie_chart_data).to eql([{ name: "Walking and cycling", y: 0 }, { name: "Car", y: 0 }, { name: "Public transport", y: 0 }, { name: "Park and stride", y: 0 }, { name: "Other", y: 0 }])
        end
      end
    end
  end

  describe "time based methods" do
    subject(:transport_survey) { create :transport_survey }

    def create_responses(times, cat)
      times.each do |time|
        transport_type = create(:transport_type, category: cat)
        create(:transport_survey_response, transport_survey: transport_survey, transport_type: transport_type, journey_minutes: time)
      end
    end

    describe "#responses_per_time_for_category" do
      let(:category) { :car }

      context "when there is one response for each time" do
        before { create_responses(TransportSurvey::Response.journey_minutes_options, category) }

        it "returns a hash of responses count per time" do
          expect(transport_survey.responses_per_time_for_category(category)).to eql({ 5 => 1, 10 => 1, 15 => 1, 20 => 1, 30 => 1, 45 => 1, 60 => 1 })
        end
      end

      context "when there is more than one response for a time" do
        before do
          create_responses(TransportSurvey::Response.journey_minutes_options, category)
          create_responses(TransportSurvey::Response.journey_minutes_options.drop(1), category)
        end

        it "adds up responses" do
          expect(transport_survey.responses_per_time_for_category(category)).to eql({ 5 => 1, 10 => 2, 15 => 2, 20 => 2, 30 => 2, 45 => 2, 60 => 2 })
        end
      end

      context "when there are no responses for some times" do
        before { create_responses(TransportSurvey::Response.journey_minutes_options[..0], category) }

        it "has zero values for those times" do
          expect(transport_survey.responses_per_time_for_category(category)).to eql({ 5 => 1, 10 => 0, 15 => 0, 20 => 0, 30 => 0, 45 => 0, 60 => 0 })
        end
      end

      context "when there are responses for more than one cateogory" do
        before do
          create_responses(TransportSurvey::Response.journey_minutes_options[..0], category)
          create_responses(TransportSurvey::Response.journey_minutes_options[..0], :park_and_stride)
        end

        it "only counts those in specified category" do
          expect(transport_survey.responses_per_time_for_category(category)).to eql({ 5 => 1, 10 => 0, 15 => 0, 20 => 0, 30 => 0, 45 => 0, 60 => 0 })
        end
      end
    end

    describe "#responses_per_time_for_category_car" do
      let(:category) { :car }

      context "when there is one response for each time" do
        before { create_responses(TransportSurvey::Response.journey_minutes_options, category) }

        it "sums 30+ minutes together" do
          expect(transport_survey.responses_per_time_for_category_car).to eql({ 5 => 1, 10 => 1, 15 => 1, 20 => 1, '30+' => 3 })
        end
      end

      context "when there is more than one response for a time" do
        before do
          create_responses(TransportSurvey::Response.journey_minutes_options, category)
          create_responses(TransportSurvey::Response.journey_minutes_options.drop(1), category)
        end

        it "sums 30+ minutes together" do
          expect(transport_survey.responses_per_time_for_category_car).to eql({ 5 => 1, 10 => 2, 15 => 2, 20 => 2, '30+' => 6 })
        end
      end
    end
  end

  describe "#today?" do
    context "when survey has a run_on date of today" do
      subject(:transport_survey) { create :transport_survey, run_on: Time.zone.today }

      it { expect(transport_survey.today?).to be true }
    end

    context "when survey has a run_on date other than today" do
      subject(:transport_survey) { create :transport_survey, run_on: 3.days.ago }

      it { expect(transport_survey.today?).to be false }
    end
  end

  describe "#add_observation" do
    context "when there are no responses" do
      subject(:transport_survey) { create :transport_survey, run_on: Time.zone.today, responses: [] }

      it 'does not add an observation' do
        expect(transport_survey.observations).to be_empty
      end
    end

    context "with responses" do
      subject(:transport_survey) { create :transport_survey, run_on: Time.zone.today }

      let(:attributes) { attributes_for(:transport_survey_response, surveyed_at: Time.zone.now, run_identifier: '2345') }

      before { transport_survey.responses = [attributes] }

      it 'adds an observation' do
        expect(transport_survey.responses.length).to eql(1)
        expect(Observation.find_by(observable: transport_survey)).not_to be_nil
        expect(transport_survey.reload.observations.length).to eql(1)
      end

      context "when transport survey is removed" do
        before do
          transport_survey.destroy
        end

        it 'removes observation' do
          expect(Observation.find_by(observable: transport_survey)).to be_nil
        end
      end

      context "when more responses are added" do
        let(:new_attributes) { attributes_for(:transport_survey_response, surveyed_at: Time.zone.now, run_identifier: '4567') }

        before { transport_survey.responses = [new_attributes] }

        it "doesn't add another observation" do
          expect(transport_survey.responses.length).to eql(2)
          expect(transport_survey.reload.observations.length).to eql(1)
        end
      end
    end
  end
end

require 'rails_helper'

describe 'TransportSurvey' do

  context "with valid attributes" do
    subject { create :transport_survey }
    it { is_expected.to be_valid }
  end

  describe "#responses=" do
    subject { create :transport_survey }

    describe "adding a response" do
      let(:attributes) { attributes_for(:transport_survey_response, surveyed_at: surveyed_at, run_identifier: run_identifier) }
      let(:surveyed_at) { DateTime.new(2021,03,18,9,0,0) }
      let(:run_identifier) { 1234 }

      before(:each) { subject.responses = [attributes] }
      it { expect(subject.responses.length).to eql 1 }

      describe "adding another response" do
        let(:new_attributes) { attributes_for(:transport_survey_response, surveyed_at: new_surveyed_at, run_identifier: new_run_identifier) }
        before(:each) { subject.responses = [new_attributes] }

        context "with the same run_identifier" do
          let(:new_run_identifier) { run_identifier }

          context "and the same surveyed_at time" do
            let(:new_surveyed_at) { surveyed_at }
            it { expect(subject.responses.length).to eql 1 }
          end

          context "and different surveyed_at time" do
            let(:new_surveyed_at) { DateTime.new(2022,03,18,9,0,0) }
            it { expect(subject.responses.length).to eql 2 }
          end
        end

        context "with a different run_identifier" do
          let(:new_run_identifier) { 9999 }

          context "and the same surveyed_at time" do
            let(:new_surveyed_at) { surveyed_at }
            it { expect(subject.responses.length).to eql 2 }
          end

          context "and a different surveyed_at time" do
            let(:new_surveyed_at) { DateTime.new(2022,03,18,9,0,0) }
            it { expect(subject.responses.length).to eql 2 }
          end
        end
      end
    end
  end

  describe "#total_passengers" do
    subject { create :transport_survey }
    context "with no responses" do
      it { expect(subject.total_passengers).to eql 0 }
    end

    context "with one response" do
      before(:each) do
        create :transport_survey_response, transport_survey: subject, passengers: 2
      end
      it { expect(subject.total_passengers).to eql 2 }
    end
    context "with more than one response" do
      before(:each) do
        create :transport_survey_response, transport_survey: subject, passengers: 2
        create :transport_survey_response, transport_survey: subject, passengers: 3
      end
      it { expect(subject.total_passengers).to eql 5 }
    end
  end

  describe "#total_carbon" do
    pending "being written"
  end

  describe "#today?" do
    context "when survey has a run_on date of today" do
      subject { create :transport_survey, run_on: Time.zone.today }
      it { expect(subject.today?).to be true }
    end

    context "when survey has a run_on date other than today" do
      subject { create :transport_survey, run_on: 3.days.ago }
      it { expect(subject.today?).to be false }
    end
  end

end

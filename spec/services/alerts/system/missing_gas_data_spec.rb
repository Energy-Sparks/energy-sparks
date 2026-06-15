require 'rails_helper'

describe Alerts::System::MissingGasData do
  let(:school)  { create :school }
  let(:today) { Time.zone.today }

  let(:gas_amr_data) { instance_double('gas-amr-data') }
  let(:gas_aggregate_meter) { instance_double('gas-aggregated-meter')}

  let(:meter_collection) { instance_double('meter-collection') }

  before do
    allow(gas_amr_data).to receive(:end_date).and_return(gas_end_date)
    allow(gas_aggregate_meter).to receive(:amr_data).and_return(gas_amr_data)
  end

  let(:report) { Alerts::System::MissingGasData.new(school: school, aggregate_school: meter_collection, today: today, alert_type: nil).report }

  context 'where the school has only gas data older than the last 2 weeks (late running meters)' do
    let(:gas_end_date) { today - 21.days }

    before do
      allow(meter_collection).to receive(:aggregated_heat_meters).and_return(gas_aggregate_meter)
    end

    it 'is valid' do
      expect(report.valid).to eq(true)
    end

    it 'has a rating related to the number of days late' do
      expect(report.rating).to eq(3.0)
    end

    it 'has enough data' do
      expect(report.enough_data).to eq(:enough)
    end

    it 'is relevant' do
      expect(report.relevance).to eq(:relevant)
    end

    it 'has no template variables' do
      expect(report.template_data).to be_empty
    end

    it 'has a priority relevance of 5' do
      expect(report.priority_data[:time_of_year_relevance]).to eq(5)
    end
  end

  context 'where the school has gas data within the last 2 weeks' do
    let(:gas_end_date) { today - 14.days }

    before do
      allow(meter_collection).to receive(:aggregated_heat_meters).and_return(gas_aggregate_meter)
    end

    it 'is valid' do
      expect(report.valid).to eq(true)
    end

    it 'has a rating of 10' do
      expect(report.rating).to eq(10.0)
    end

    it 'has enough data' do
      expect(report.relevance).to eq(:relevant)
    end

    it 'does not have mpan_mprns as a variable' do
      expect(report.template_data).to eq({})
      expect(report.template_data_cy).to eq({})
    end

    it 'has a priority relevance of 5' do
      expect(report.priority_data[:time_of_year_relevance]).to eq(5)
    end
  end

  context 'where the school has no gas meters' do
    let(:gas_end_date) { today }

    before { allow(meter_collection).to receive(:aggregated_heat_meters).and_return(nil) }

    it 'is valid' do
      expect(report.valid).to eq(true)
    end

    it 'has no rating' do
      expect(report.rating).to eq(nil)
    end

    it 'has not enough data' do
      expect(report.enough_data).to eq(:not_enough)
    end

    it 'is never relevant' do
      expect(report.relevance).to eq(:never_relevant)
    end
  end
end

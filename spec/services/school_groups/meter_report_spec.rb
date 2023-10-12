require 'rails_helper'

RSpec.describe SchoolGroups::MeterReport do
  let(:frozen_time) { Time.zone.now }
  before { Timecop.freeze(frozen_time) }
  after { Timecop.return }

  let(:school_group) { create :school_group, name: 'A Group' }
  let(:all_meters) { false }
  subject(:meter_report) { SchoolGroups::MeterReport.new(school_group, all_meters: all_meters) }

  let!(:school)       { create(:school, school_group: school_group) }
  let!(:active_meter) { create :gas_meter, active: true, school: school }
  let!(:inactive_meter) { create :gas_meter, active: false, school: school }

  let(:header) { 'School,Supply,Number,Meter,Half-Hourly,Data source,Admin meter status,Procurement route,Active,First validated reading,Last validated reading,Large gaps (last 2 years),Modified readings (last 2 years),Zero reading days' }

  describe "#csv_filename" do
    context "when all_meters is false" do
      let(:all_meters) { false }
      it { expect(meter_report.csv_filename).to eq("a-group-meter-report-#{frozen_time.iso8601.parameterize}.csv") }
    end

    context "when all_meters is true" do
      let(:all_meters) { true }
      it { expect(meter_report.csv_filename).to eq("a-group-meter-report-#{frozen_time.iso8601.parameterize}-all-meters.csv") }
    end
  end

  describe "#csv" do
    subject(:csv) { meter_report.csv }

    context "only active meters" do
      let(:all_meters) { false }
      it { expect(csv.lines.first.chomp).to eq(header) }
      it { expect(csv.lines.count).to eq(2) }
      it { expect(csv.lines.second).to include(active_meter.school_name) }

      context 'and the school is inactive' do
        let!(:school) { create(:school, school_group: school_group, active: false) }
        it { expect(csv.lines.first.chomp).to eq(header) }
        it { expect(csv.lines.count).to eq(1) }
      end
    end

    context "all meters" do
      let(:all_meters) { true }

      it { expect(csv.lines.first.chomp).to eq(header) }
      it { expect(csv.lines.count).to eq(3) }
      it { expect(csv).to include(active_meter.school_name) }
      it { expect(csv).to include(inactive_meter.school_name) }
    end
  end
end

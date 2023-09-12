require 'rails_helper'

RSpec.describe ProcurementRoute, type: :model do

  describe 'validations' do
    subject { build(:procurement_route) }
    it { is_expected.to be_valid }
    it { is_expected.to validate_presence_of(:organisation_name) }
  end

  describe ".to_csv" do
    let(:procurement_route) { create(:procurement_route) }
    let(:data_source) { create(:data_source) }
    subject { procurement_route.to_csv }
    let(:header) { "School group,School,MPAN/MPRN,Meter type,Active,Half-Hourly,First validated meter reading,Last validated meter reading,Admin Meter Status,Data Source,Open issues count,Open issues" }
    before { Timecop.freeze }
    after { Timecop.return }

    context "with meters" do
      let(:admin_meter_status) { AdminMeterStatus.create(label: "On Data Feed") }
      let!(:meters) do
        [create(:gas_meter, data_source: data_source, procurement_route: procurement_route, school: create(:school), admin_meter_status: admin_meter_status),
         create(:gas_meter, data_source: data_source, procurement_route: procurement_route, school: create(:school, :with_school_group), admin_meter_status: admin_meter_status)]
      end
      let(:first_reading_date) { 1.year.ago.to_date + 2.days }
      let(:last_reading_date) { 1.year.ago.to_date + 4.days }

      before do
        meters.each do |meter|
          create(:amr_validated_reading, meter: meter, reading_date: first_reading_date)
          create(:amr_validated_reading, meter: meter, reading_date: last_reading_date)

          issue = create(:issue, issue_type: :issue, status: :open)
          issue.meters << meter
          issue.save!
        end
      end

      it { expect(subject.lines.count).to eq(3) }
      it { expect(subject.lines.first.chomp).to eq(header) }
      2.times do |i|
        it do
          expect(subject.lines[i + 1].chomp).to eq(
            (
              [
                meters[i].school.school_group.try(:name),
                meters[i].school.name,
                meters[i].mpan_mprn,
                meters[i].meter_type.humanize,
                meters[i].active,
                meters[i].t_meter_system,
                first_reading_date,
                last_reading_date,
                admin_meter_status.label,
                meters[i]&.data_source&.name,
                1
              ] + meters[i]&.open_issues_as_list
            ).join(',')
          )
        end
      end
    end

    context "with meters for other data source" do
      let!(:meters) do
        [create(:gas_meter),
         create(:gas_meter)]
      end
      it { expect(subject.lines.count).to eq(1) }
    end

    context "with no meters" do
      it { expect(subject.lines.count).to eq(1) }
      it { expect(subject.lines.first.chomp).to eq(header) }
    end
  end
end

require 'rails_helper'

RSpec.describe DataSource, type: :model do
  describe 'validations' do
    subject { build(:data_source) }

    it { is_expected.to be_valid }
    it { is_expected.to validate_presence_of(:name) }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:organisation_type).with_values([:energy_supplier, :procurement_organisation, :meter_operator, :council, :solar_monitoring_provider]) }
  end

  describe '.to_csv' do
    let(:data_source) { create(:data_source) }
    subject { data_source.to_csv }

    let(:header) { 'School group,Admin,School,MPAN/MPRN,Meter type,Active,Half-Hourly,First validated meter reading,Last validated meter reading,Admin Meter Status,Open issues count,Open issues' }

    before { freeze_time }

    context 'with meters' do
      let(:admin_meter_status) { AdminMeterStatus.create(label: 'On Data Feed') }
      let!(:meters) do
        school_group = create(:school_group, default_issues_admin_user: create(:admin))
        [
          create(:gas_meter, data_source: data_source, school: create(:school, active: true), admin_meter_status: admin_meter_status, created_at: 3.seconds.ago),
          create(:gas_meter, data_source: data_source, school: create(:school, school_group: school_group, active: true), admin_meter_status: admin_meter_status, created_at: 2.seconds.ago),
          create(:gas_meter, data_source: data_source, school: create(:school, active: false), admin_meter_status: admin_meter_status, created_at: 1.second.ago)
        ]
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
        it 'returns rows for all meters for active schools with this data source' do
          expect(subject.lines[i + 1].chomp).to eq(
            (
              [
                meters[i].school.school_group.try(:name),
                meters[i].school.school_group&.default_issues_admin_user&.try(:name),
                meters[i].school.name,
                meters[i].mpan_mprn,
                meters[i].meter_type.humanize,
                meters[i].active,
                meters[i].t_meter_system,
                first_reading_date,
                last_reading_date,
                admin_meter_status.label,
                1
              ] + meters[i]&.open_issues_as_list
            ).join(',')
          )
        end
      end
    end

    context 'with meters for other data source' do
      let!(:meters) do
        create_list(:gas_meter, 2)
      end

      it { expect(subject.lines.count).to eq(1) }
    end

    context 'with no meters' do
      it { expect(subject.lines.count).to eq(1) }
      it { expect(subject.lines.first.chomp).to eq(header) }
    end
  end
end

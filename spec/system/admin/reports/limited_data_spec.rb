# frozen_string_literal: true

require 'rails_helper'

describe 'Limited data report' do
  let(:school) { create(:school, :with_school_group) }
  let!(:meter) do
    create(:electricity_meter_with_validated_reading,
           school:, data_source: create(:data_source), supplier: create(:supplier), admin_meter_status:
           create(:admin_meter_status))
  end

  before do
    sign_in(create(:admin))
    visit admin_reports_path
    click_on 'Limited data'
  end

  it_behaves_like 'it contains the expected data table', aligned: false do
    let(:table_id) { '.advice-table' }
    let(:expected_header) do
      [['School Group', 'Admin', 'School', 'Meter', 'Meter Name',
        'Meter Type', 'Meter System', 'Supplier', 'Data Source', 'Procurement Route', 'Admin Meter Status',
        'Manual Reads', 'Last Validated Date', 'Issues & Notes']]
    end
    let(:expected_rows) do
      [[school.school_group.name, school.default_issues_admin_user.name, school.name, meter.mpan_mprn.to_s, meter.name,
        '', 'NHH AMR', meter.supplier.name, meter.data_source.name, '', meter.admin_meter_status.label,
        'N', 3.days.ago.to_fs(:es_full), '']]
    end
  end

  context 'with CSV' do
    before { click_on 'CSV' }

    it 'is correct' do
      expect(CSV.parse(page.body)).to eq(
        [['School Group', 'Admin', 'School', 'Meter',
          'Meter Name', 'Meter Type', 'Meter System', 'Supplier', 'Data Source', 'Procurement Route',
          'Admin Meter Status', 'Manual Reads', 'Last Validated Date', 'Issues', 'Notes'],
         [school.school_group.name, school.default_issues_admin_user.name, school.name, meter.mpan_mprn.to_s,
          meter.name, 'electricity', 'NHH AMR', meter.supplier.name, meter.data_source.name, nil,
          meter.admin_meter_status.label, 'N', 4.days.ago.to_date.iso8601, '0', '0']]
      )
    end
  end
end

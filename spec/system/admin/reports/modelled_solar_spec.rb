# frozen_string_literal: true

require 'rails_helper'

describe 'Modelled solar report' do
  let(:school) { create(:school, :with_school_group) }
  let!(:meter) do
    meter = create(:electricity_meter, school:, data_source: create(:data_source), supplier: create(:supplier),
                                       admin_meter_status: create(:admin_meter_status))
    create(:solar_pv_attribute, meter:)
    meter
  end

  before do
    sign_in(create(:admin))
    visit admin_reports_path
    click_on 'Modelled'
  end

  it_behaves_like 'it contains the expected data table', aligned: false do
    let(:table_id) { '.advice-table' }
    let(:expected_header) do
      [['School Group', 'Admin', 'School', 'Meter', 'Active',
        'Supplier', 'Data Source', 'Admin Meter Status', 'Start Date', 'End Date', 'kWp', '']]
    end
    let(:expected_rows) do
      [[school.school_group.name, school.default_issues_admin_user.name, school.name, meter.mpan_mprn.to_s, '',
        meter.supplier.name, meter.data_source.name, meter.admin_meter_status.label, '2023-01-01', '2024-01-01', '15.0',
        'Attributes']]
    end
  end

  context 'with CSV' do
    before { click_on 'CSV' }

    it 'is correct' do
      expect(CSV.parse(page.body)).to eq(
        [['School Group', 'Admin', 'School', 'Meter', 'Active',
          'Supplier', 'Data Source', 'Admin Meter Status', 'Start Date', 'End Date',
          'kWp'],
         [school.school_group.name, school.default_issues_admin_user.name, school.name, meter.mpan_mprn.to_s, 'Yes',
          meter.supplier.name, meter.data_source.name, meter.admin_meter_status.label, '2023-01-01', '2024-01-01',
          '15.0']]
      )
    end
  end
end

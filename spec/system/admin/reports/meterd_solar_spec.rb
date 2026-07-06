# frozen_string_literal: true

require 'rails_helper'

describe 'Meter solar report' do
  let(:school) { create(:school, :with_school_group) }
  let!(:meter) do
    meter = create(:electricity_meter, school:, data_source: create(:data_source), supplier: create(:supplier),
                                       admin_meter_status: create(:admin_meter_status))
    create(:solar_pv_mpan_meter_mapping, meter:)
    create(:solar_pv_attribute, meter:)
    meter
  end

  before do
    sign_in(create(:admin))
    visit admin_reports_path
    click_on 'Metered Solar'
  end

  it_behaves_like 'it contains the expected data table', aligned: false do
    let(:table_id) { '.advice-table' }
    let(:expected_header) do
      [['School Group', 'Admin', 'School', 'Meter', 'Active',
        'Supplier', 'Data Source', 'Meter Status', 'Real Generation Meters',
        'Modelled Solar Pv Generation?', 'Modelled Solar?', 'Solar Overrides?', '']]
    end
    let(:expected_rows) do
      [[school.school_group.name, school.default_issues_admin_user.name, school.name, meter.mpan_mprn.to_s, '',
        meter.supplier.name, meter.data_source.name, meter.admin_meter_status.label, '1',
        '', '', '', 'Attributes']]
    end
  end

  context 'with CSV' do
    before { click_on 'CSV' }

    it 'is correct' do
      expect(CSV.parse(page.body)).to eq(
        [['School Group', 'Admin', 'School', 'Meter', 'Active',
          'Supplier', 'Data Source', 'Meter Status', 'Real Generation Meters',
          'Modelled Solar Pv Generation?', 'Modelled Solar?', 'Solar Overrides?'],
         [school.school_group.name, school.default_issues_admin_user.name, school.name, meter.mpan_mprn.to_s, 'Yes',
          meter.supplier.name, meter.data_source.name, meter.admin_meter_status.label, '1',
          'No', 'Yes', 'No']]
      )
    end
  end
end

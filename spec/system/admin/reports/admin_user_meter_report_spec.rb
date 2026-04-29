# frozen_string_literal: true

require 'rails_helper'

describe 'admin user meter report' do
  let(:school) { create(:school, :with_school_group) }
  let!(:meter) { create(:gas_meter, school:) }
  let!(:before) do
    sign_in school.school_group.default_issues_admin_user
    visit admin_reports_admin_user_meter_report_index_path
  end

  it_behaves_like 'it contains the expected data table', aligned: false do
    let(:table_id) { '.advice-table' }
    let(:expected_header) do
      [['School Group', 'Admin', 'School', 'Meter', 'Meter Name', 'Meter Type', 'Meter System', 'Data Source',
        'Procurement Route', 'Meter Status', 'Manual Reads', 'Last Validated Date', 'Issues & Notes']]
    end
    let(:expected_rows) do
      [[school.school_group.name, 'Admin', school.name, meter.mpan_mprn.to_s, meter.name, '', 'NHH AMR', '', '', '',
        'N', '', '']]
    end
  end

  RSpec.shared_examples 'it has the correct CSV' do
    before { click_on 'CSV' }

    it 'has the correct CSV' do
      # debugger
      expect(CSV.parse(page.body)).to eq(
        [['School Group', 'Admin', 'School', 'Meter', 'Meter Name', 'Meter Type', 'Meter System', 'Data Source',
          'Procurement Route', 'Meter Status', 'Manual Reads', 'Last Validated Date', 'Issues', 'Notes'],
         [school.school_group.name, 'Admin', school.name, meter.mpan_mprn.to_s, meter.name, 'gas', 'NHH AMR',
          nil, nil, nil, 'N', nil, '0', '0']]
      )
    end
  end

  it_behaves_like 'it has the correct CSV'

  context 'with admin filter' do
    let!(:before) do
      admin = create(:admin, name: 'Another Admin')
      create(:gas_meter, school: create(:school, :with_school_group, default_issues_admin_user: admin))
      sign_in admin
      visit admin_reports_admin_user_meter_report_index_path
      select 'Admin', from: 'Admin', exact: true
      click_on 'Filter'
    end

    it_behaves_like 'it has the correct CSV'
  end
end

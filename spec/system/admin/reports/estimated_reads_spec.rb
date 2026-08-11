# frozen_string_literal: true

require 'rails_helper'

describe 'Estimated Reads Report' do
  let!(:school) do
    create(:school, school_group: create(:school_group, default_issues_admin_user: create(:admin)))
  end

  let(:page_title) { 'Estimated data report' }

  let!(:meter) do
    create(:gas_meter_with_validated_reading_dates,
           school: school,
           start_date: Time.zone.today - 60.days,
           end_date: Time.zone.yesterday,
           data_source: create(:data_source),
           supplier: create(:supplier),
           status: 'EST')
  end

  before do
    sign_in(create(:admin))
    visit root_path
    click_on 'Manage'
    click_on 'Reports'
    click_on page_title
  end

  it_behaves_like 'an admin meter report', help: true do
    let(:title) { page_title }
    let(:description) { 'Lists all active meters in the system that have one or more Estimated (EST) data readings' }
  end

  it_behaves_like 'it contains the expected data table', aligned: false do
    let(:table_id) { '.advice-table' }
    let(:expected_header) do
      [
        ['School Group', 'Admin', 'School', 'Meter', 'Meter Name',
         'Meter Type', 'Meter System', 'Supplier', 'Data Source', 'Admin Meter Status',
         'Last Validated Date', 'Last Estimated Read', 'Total', 'Recent']
      ]
    end
    let(:expected_rows) do
      [[school.school_group.name, school.default_issues_admin_user.name, school.name, meter.mpan_mprn.to_s, meter.name,
        '', 'NHH AMR', meter.supplier.name, meter.data_source.name, '',
        Time.zone.yesterday.iso8601, Time.zone.yesterday.iso8601, '60', '30']]
    end
  end

  it 'allows csv download'
end

# frozen_string_literal: true

require 'rails_helper'

describe 'Solar installations report' do
  let(:school) { create(:school, :with_school_group) }

  before do
    create(:solar_edge_installation, school:)
    create(:low_carbon_hub_installation, school:)
    create(:rtone_variant_installation, school:)
    create(:solis_cloud_installation).schools << school
    # debugger
  end

  # let!(:meter) do
  #   meter = create(:electricity_meter, school:, data_source: create(:data_source), supplier: create(:supplier),
  #                                      admin_meter_status: create(:admin_meter_status))
  #   create(:solar_pv_mpan_meter_mapping, meter:, export_mpan: '55555')
  #   create(:solar_pv_attribute, meter:)
  #   meter
  # end

  before do
    sign_in(create(:admin))
    visit admin_reports_path
    click_on 'Solar Installations'
  end

  it_behaves_like 'it contains the expected data table', aligned: false do
    let(:table_id) { '.advice-table' }
    let(:expected_header) do
      [['School Group', 'Admin', 'School',
        'SolarEdge Active', 'SolarEdge Inactive',
        'Rtone Active', 'Rtone Inactive',
        'Rtone Variant Active', 'Rtone Variant Inactive',
        'SolisCloud Active', 'SolisCloud Inactive',
        '']]
    end
    let(:expected_rows) do
      [[school.school_group.name, school.default_issues_admin_user.name, school.name,
        '1', '0',
        '1', '0',
        '1', '0',
        '1', '0',
        'Solar Feeds']]
    end
  end

  context 'with CSV' do
    before { click_on 'CSV' }

    it 'is correct' do
      expect(CSV.parse(page.body)).to eq(
        [['School Group', 'Admin', 'School',
          'SolarEdge Active', 'SolarEdge Inactive',
          'Rtone Active', 'Rtone Inactive',
          'Rtone Variant Active', 'Rtone Variant Inactive',
          'SolisCloud Active', 'SolisCloud Inactive'],
         [school.school_group.name, school.default_issues_admin_user.name, school.name,
          '1', '0',
          '1', '0',
          '1', '0',
          '1', '0']]
      )
    end
  end
end

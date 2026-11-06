# frozen_string_literal: true

require 'rails_helper'

describe 'SolarEdge status report' do
  let!(:school) { create(:school, :with_school_group) }

  def csv_headers
    ['School Group', 'Admin', 'School', 'Site',
     'Consented?', 'Loading Enabled?', 'Metered Solar Configured?',
     'Solar Meter Active?', 'Export Meter Active?', 'Electricity Meter Active?',
     'Daily Credit Estimate']
  end

  def html_headers = [csv_headers + ['']]

  before do
    sign_in(create(:admin))
    visit admin_reports_path
  end

  context 'with a consented installation' do
    let!(:solar_edge_installation) { create(:solar_edge_installation_with_meters_and_validated_readings, school:) }

    before { click_on 'SolarEdge Status' }

    it_behaves_like 'it contains the expected data table', aligned: false do
      let(:table_id) { '.advice-table' }
      let(:expected_header) { html_headers }
      let(:expected_rows) do
        [
          [
            school.school_group.name,
            school.default_issues_admin_user.name,
            school.name,
            solar_edge_installation.site_id,
            '', '', '', '', '', '', '8', 'Solar Feeds'
          ]
        ]
      end
    end

    context 'when selecting CSV' do
      before { click_on 'CSV' }

      it 'is correct' do
        expect(CSV.parse(page.body)).to eq([
                                             csv_headers,
                                             [
                                               school.school_group.name,
                                               school.default_issues_admin_user.name,
                                               school.name,
                                               solar_edge_installation.site_id,
                                               'Yes', 'Yes', 'No', 'Yes', 'Yes', 'Yes', '8'
                                             ]
                                           ])
      end
    end
  end

  context 'with meter attribute configured' do
    let!(:solar_edge_installation) do
      installation = create(:solar_edge_installation_with_meters_and_validated_readings, school:)
      meter = create(:electricity_meter, school:)
      create(:solar_pv_mpan_meter_mapping, meter:, production_mpan: installation.meters.solar_pv.first)
      installation
    end

    before { click_on 'SolarEdge Status' }

    it_behaves_like 'it contains the expected data table', aligned: false do
      let(:table_id) { '.advice-table' }
      let(:expected_header) { html_headers }
      let(:expected_rows) do
        [
          [
            school.school_group.name,
            school.default_issues_admin_user.name,
            school.name,
            solar_edge_installation.site_id,
            '', '', '', '', '', '', '8', 'Solar Feeds'
          ]
        ]
      end
    end

    context 'when selecting CSV' do
      before { click_on 'CSV' }

      it 'is correct' do
        expect(CSV.parse(page.body)).to eq([
                                             csv_headers,
                                             [
                                               school.school_group.name,
                                               school.default_issues_admin_user.name,
                                               school.name,
                                               solar_edge_installation.site_id,
                                               'Yes', 'Yes', 'Yes', 'Yes', 'Yes', 'Yes', '8'
                                             ]
                                           ])
      end
    end
  end
end

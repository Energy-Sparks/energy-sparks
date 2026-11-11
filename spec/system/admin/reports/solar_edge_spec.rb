# frozen_string_literal: true

require 'rails_helper'

describe 'SolarEdge status report' do
  let!(:school) { create(:school, :with_school_group) }

  def csv_headers
    ['School Group', 'School', 'Admin', 'Site',
     'Consented?', 'Loading Enabled?', 'Metered Solar Configured?',
     'Solar Meter Active?', 'Export Meter Active?', 'Electricity Meter Active?',
     'Daily Credit Estimate']
  end

  def html_headers = [csv_headers + ['']]

  # rubocop:disable-next Metrics/ParameterLists
  def row(consented, loading, metered_solar, solar_meter, export_meter, electricity_meter, credits)
    [
      school.school_group.name,
      school.name,
      school.default_issues_admin_user.name,
      solar_edge_installation.site_id,
      consented,
      loading,
      metered_solar,
      solar_meter,
      export_meter,
      electricity_meter,
      credits
    ]
  end

  # rubocop:disable-next Metrics/ParameterLists
  def html_row(consented, loading, metered_solar, solar_meter, export_meter, electricity_meter, credits)
    row(consented, loading, metered_solar, solar_meter, export_meter, electricity_meter, credits) + ['Solar Feeds']
  end

  before do
    sign_in(create(:admin))
    visit admin_reports_path
  end

  context 'with a consented installation' do
    # rubocop:disable-next RSpec/LetSetup
    let!(:solar_edge_installation) { create(:solar_edge_installation_with_meters_and_validated_readings, school:) }

    before { click_on 'SolarEdge Status' }

    it_behaves_like 'it contains the expected data table', aligned: false do
      let(:table_id) { '.advice-table' }
      let(:expected_header) { html_headers }
      let(:expected_rows) do
        [
          html_row('', '', '', '', '', '', '8')
        ]
      end
    end

    context 'when selecting CSV' do
      before { click_on 'CSV' }

      it 'is correct' do
        expect(CSV.parse(page.body)).to eq([
                                             csv_headers,
                                             row('Yes', 'Yes', 'No', 'Yes', 'Yes', 'Yes', '8')
                                           ])
      end
    end
  end

  context 'with meter attribute configured and inactive meters' do
    # rubocop:disable-next RSpec/LetSetup
    let!(:solar_edge_installation) do
      installation = create(:solar_edge_installation_with_meters_and_validated_readings, school:)
      installation.meters.where(meter_type: %i[electricity exported_solar_pv]).find_each do |meter|
        meter.update(active: false)
      end

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
          html_row('', '', '', '', '', '', '4')
        ]
      end
    end

    context 'when selecting CSV' do
      before { click_on 'CSV' }

      it 'is correct' do
        expect(CSV.parse(page.body)).to eq([
                                             csv_headers,
                                             row('Yes', 'Yes', 'Yes', 'Yes', 'No', 'No', '4')
                                           ])
      end
    end
  end
end

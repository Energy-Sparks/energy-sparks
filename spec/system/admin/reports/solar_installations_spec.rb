# frozen_string_literal: true

require 'rails_helper'

describe 'Solar installations report' do
  let!(:school) do
    school = create(:school, :with_school_group)
    create(:solar_edge_installation, school:)
    create(:low_carbon_hub_installation, school:, active: false)
    create(:rtone_variant_installation, school:)
    create(:solis_cloud_installation).schools << school
    school
  end
  let(:installation_counts) do
    { solar_edge_active: 1, rtone_inactive: 1, rtone_variant_active: 1, solis_cloud_active: 1 }
  end

  def csv_headers
    ['School Group', 'Admin', 'School',
     'SolarEdge Active', 'SolarEdge Inactive',
     'Rtone Active', 'Rtone Inactive',
     'Rtone Variant Active', 'Rtone Variant Inactive',
     'SolisCloud Active', 'SolisCloud Inactive']
  end

  def html_headers = [csv_headers + ['']]

  def counts_hash_to_a(hash)
    %i[solar_edge rtone rtone_variant solis_cloud].product(%i[active inactive]).map do |type|
      hash.fetch(type.join('_').to_sym, 0).to_s
    end
  end

  def row
    [school.school_group.name, school.default_issues_admin_user.name, school.name,
     *counts_hash_to_a(installation_counts)]
  end

  def html_row = [row + ['Solar Feeds']]

  before do
    create(:school, :with_school_group) # school with no installations

    sign_in(create(:admin))
    visit admin_reports_path
    click_on 'Solar Installations'
  end

  it_behaves_like 'it contains the expected data table', aligned: false do
    let(:table_id) { '.advice-table' }
    let(:expected_header) { html_headers }
    let(:expected_rows) { html_row }
  end

  context 'with CSV' do
    before { click_on 'CSV' }

    it 'is correct' do
      expect(CSV.parse(page.body)).to eq([csv_headers, row])
    end
  end

  context 'when filtering by installation type' do
    let(:school) { create(:solar_edge_installation, school: create(:school, :with_school_group)).school }
    let(:installation_counts) { { solar_edge_active: 1 } }

    before do
      create(:low_carbon_hub_installation, school: create(:school, :with_school_group))
      select 'SolarEdge', from: 'installation_type'
      click_on 'Filter'
    end

    it_behaves_like 'it contains the expected data table', aligned: false do
      let(:table_id) { '.advice-table' }
      let(:expected_header) { html_headers }
      let(:expected_rows) { html_row }
    end
  end
end

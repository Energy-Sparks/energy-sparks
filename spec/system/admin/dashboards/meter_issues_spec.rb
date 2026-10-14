# frozen_string_literal: true

require 'rails_helper'

describe 'Admin dashboard - Meter Issues' do
  let(:admin) { create(:admin, operations: true) }
  let(:link) { 'Meter issues' }
  let(:issue) do
    issue = create(:issue, issueable: create(:supplier))
    school = create(:school, school_group: create(:school_group, default_issues_admin_user: admin))
    issue.meters << create(:gas_meter, school:)
    issue
  end

  before do |example|
    travel_to(Date.new(2026))
    sign_in(admin)
    visit admin_dashboards_url
    issue
    find('.application').click_on(admin.name)
    click_on link || example.example_group.description
  end

  it_behaves_like 'it contains the expected data table', sortable: false, aligned: false do
    let(:table_id) { '.table' }
    let(:expected_header) do
      [['', 'Title', 'Fuel', 'Created by', 'Status', 'Updated', 'Next review', '']]
    end
    let(:expected_rows) do
      [['', "#{issue.title} #{issue.issueable.name} #{issue.meters.first.mpan_mprn}", 'Gas', 'user 5', 'Open',
        '00:00 today', 'No date set', 'Edit']]
    end
  end

  context 'with owned issue' do
    let(:issue) { create(:issue, issueable: create(:supplier), owned_by: admin) }

    it { expect(page).to have_text('No issues or notes to display.') }
  end

  context 'with no issues' do
    let(:issue) { nil }

    it { expect(page).to have_text('No issues or notes to display.') }
  end
end

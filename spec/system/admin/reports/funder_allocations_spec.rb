# frozen_string_literal: true

require 'rails_helper'

describe 'FunderAllocations' do
  before do
    funder = Funder.create(name: 'A funder')
    create(:school, funder:)
    create(:school_onboarding, funder:)
    sign_in(create(:admin))
  end

  it 'shows the expected table' do
    visit admin_reports_funder_allocations_path
    headers = ['Funder', 'Visible not data enabled', 'Visible and data enabled', 'Onboarding', 'Total']
    rows = [['A funder', '0', '1', '1', '2'], ['No funder', '0', '0', '0', '0']]
    expect(page).to have_selector(:table, rows: rows.map { |row| headers.zip(row).to_h })
  end
end

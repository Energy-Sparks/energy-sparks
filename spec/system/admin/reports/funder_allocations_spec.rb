# frozen_string_literal: true

require 'rails_helper'

describe 'FunderAllocations' do
  before do
    create(:school, funder: Funder.create(name: 'Big Energy Co.'))
    sign_in(create(:admin))
  end

  it 'shows the expected table' do
    visit admin_reports_funder_allocations_path
    expect(page).to have_selector(:table_row, {
                                    'Funder' => 'Big Energy Co.',
                                    'Visible not data enabled' => '0',
                                    'Visible and data enabled' => '1'
                                  })
  end
end

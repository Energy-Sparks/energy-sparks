# frozen_string_literal: true

require 'rails_helper'

describe 'Missing Alert Contacts' do
  let!(:school) do
    create(:school, :with_school_group, active: true, funder: create(:funder))
  end

  before do
    sign_in(create(:admin))
    visit root_path
    click_on 'Manage'
    click_on 'Reports'
  end

  it 'shows the expected table' do
    click_on 'Missing Alert Subscribers'

    expect(page).to have_selector(:table_row, {
                                    'School Group' => school.school_group.name,
                                    'School' => school.name,
                                    'Funder' => school.funder.name,
                                    'Country' => school.country.humanize,
                                    'Onboarding completed' => 'N/A',
                                    'Data enabled?' => '',
                                    'Users' => '0',
                                    'Actions' => 'Users'
                                  })
  end
end

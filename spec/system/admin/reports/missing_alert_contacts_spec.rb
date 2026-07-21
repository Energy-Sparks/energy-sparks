# frozen_string_literal: true

require 'rails_helper'

describe 'Missing Alert Contacts' do
  let!(:funder) { create(:funder) }
  let!(:school) { create(:school, :with_school_group, active: true) }

  before do
    create(:commercial_licence, school:, contract: create(:commercial_contract, contract_holder: funder))

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
                                    'Admin' => school.school_group.default_issues_admin_user.name,
                                    'Funder' => funder.name,
                                    'Country' => school.country.humanize,
                                    'Onboarding completed' => 'N/A',
                                    'Data enabled?' => '',
                                    'Users' => '0',
                                    'Actions' => 'Users'
                                  })
  end
end

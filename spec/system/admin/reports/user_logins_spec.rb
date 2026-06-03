# frozen_string_literal: true

require 'rails_helper'

describe 'user logins' do
  let!(:admin) { create(:admin) }
  let!(:school) { create(:school, :with_school_group) }

  describe 'when logged in to the admin reports index' do
    before do
      freeze_time
      sign_in(create(:pupil, school:))
      sign_in(create(:staff, school:))
      sign_in(admin)
      visit admin_reports_path
      click_on 'User logins'
      click_on 'Show'
    end

    it 'displays a table' do
      expect(page).to have_button('Show')
      expect(page).to have_selector(:table_row, {
                                      'School Name' => school.name,
                                      'Most recent adult login' => Time.current.to_s,
                                      'Most recent pupil login' => Time.current.to_s,
                                      '' => 'Manage Users'
                                    })
    end
  end
end

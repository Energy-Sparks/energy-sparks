# frozen_string_literal: true

require 'rails_helper'

describe 'work allocation' do
  let!(:admin) { create(:admin) }

  def create_data_for_school_groups
    school_groups = [create(:school_group, default_issues_admin_user: create(:admin)), create(:school_group)]

    school_groups.each do |school_group|
      create(:school_onboarding, created_by: admin, school_group:)
      create(:school, visible: true, data_enabled: true, school_group:)
      create(:school, visible: false, school_group:)
      create(:school, active: false, school_group:)
    end
  end

  describe 'when logged in to the admin index' do
    before do
      school_group = create(:school_group, default_issues_admin_user: create(:admin))
      create(:school_onboarding, created_by: admin, school_group:)
      create(:school, visible: true, data_enabled: true, school_group:)
      create(:school, visible: false, school_group:)
      create(:school, active: false, school_group:)
      create(:school_group)

      sign_in(admin)
      visit admin_reports_path
      click_on 'Work allocation'
    end

    it 'displays a table' do
      expect(page).to have_selector(:table_row, {
                                      'Name' => admin.name,
                                      'School Groups' => '1',
                                      'Onboarding' => '1',
                                      'Active' => '1',
                                      'Data visible' => '1',
                                      'Invisible' => '1',
                                      'Removed' => '1'
                                    })
    end
  end
end

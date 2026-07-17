# frozen_string_literal: true

require 'rails_helper'

describe 'Limited users report' do
  let(:user) { create(:admin) }
  let(:school_group) { create(:school_group) }

  let(:school_with_limited_users) { create(:school, school_group:) }
  let(:school_with_many_users) { create(:school, school_group:) }

  before do
    create(:school_admin, school: school_with_limited_users)
    create_list(:school_admin, 3, school: school_with_many_users)
    sign_in(user)
    visit admin_reports_path
    click_on 'Limited users'
  end

  describe 'displaying the table' do
    let(:header) do
      ['School Group', 'School', 'Admin', 'Current Funder', 'Number of School Admins', 'Number of Staff Users',
       'Total Number of Adult Users', 'Actions']
    end

    let(:expected_rows) do
      [
        header,
        [school_with_limited_users.school_group.name, school_with_limited_users.name,
         school_with_limited_users.default_issues_admin_user.name,
         '', '1', '0', '1', 'Manage Users']
      ]
    end

    it 'shows only schools with less than 3 users' do
      rows = all('tr').map { |tr| tr.all('th, td').map(&:text) }
      expect(rows).to eq(expected_rows)
    end

    it 'links to the users page' do
      expect(page).to have_link('Manage Users', href: school_users_path(school_with_limited_users))
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

describe 'Engaged Groups Report' do
  before do
    admin = create(:admin)
    create(:school, :with_points,
                    school_group: create(:school_group, name: 'Group 1', default_issues_admin_user: admin))
    create(:school, active: false,
                    school_group: create(:school_group, name: 'Group 2', default_issues_admin_user: admin))
    sign_in(admin)
    visit admin_reports_engaged_groups_path
  end

  it 'displays the correct table' do
    within_table('engaged-groups-table') do
      expect(first('tr').all('th').map(&:text)).to \
        eq(['School Group', 'Group Type', 'Admin', 'Active Schools', 'Engaged Schools', 'Percentage of Engaged Schools'])
      expect(all('tr').map { |tr| tr.all('td').map(&:text) }).to \
        eq([[],
            ['Group 1', 'General', 'Admin', '1', '1', '100%'],
            ['Group 2', 'General', 'Admin', '0', '0', '']])
    end
  end
end

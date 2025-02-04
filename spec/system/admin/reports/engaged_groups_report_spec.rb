# frozen_string_literal: true

require 'rails_helper'

describe 'Engaged Groups Report' do
  let!(:school) { create(:school, :with_school_group, :with_points) }
  let!(:inactive_school) { create(:school, :with_school_group, active: false) }

  before do
    sign_in(create(:admin))
    visit admin_reports_engaged_groups_path
  end

  it 'displays the correct table' do
    within_table('engaged-groups-table') do
      expect(first('tr').all('th').map(&:text)).to \
        eq(['School Group', 'Admin', 'Active Schools', 'Engaged Schools', 'Percentage of Engaged Schools'])
      expect(all('tr').map { |tr| tr.all('td').map(&:text) }).to \
        eq([[],
            [school.school_group.name, '', '1', '1', '100%'],
            [inactive_school.school_group.name, '', '0', '0', '']])
    end
  end
end

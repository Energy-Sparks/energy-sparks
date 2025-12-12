require 'rails_helper'

RSpec.describe 'activation', type: :system do
  let!(:admin) { create(:admin)}

  let!(:school_group) { create(:school_group, name: 'BANES') }
  let!(:not_visible)      { create(:school, name: 'Not Visible', school_group: school_group, visible: false)}
  let!(:not_data_visible) { create(:school, name: 'Data visible', school_group: school_group, visible: true, data_enabled: false) }
  let!(:onboarding) { create(:school_onboarding, school: not_data_visible, project_group: create(:school_group, :project_group)) }

  before do
    sign_in(admin)
    visit admin_path
    click_on 'Schools awaiting activation'
  end

  it 'displays the table' do
    expect(all('tr').map { |tr| tr.all('th, td').map(&:text) }).to eq(
      [
        ['School group', 'Project group', 'Admin', 'School', 'Onboarding completed', 'Visible?', 'Process data?', 'Data visible?', 'Meters', 'Awaiting meter review?', 'Issues?', 'Actions'],
        [school_group.name, onboarding.project_group.name, school_group.default_issues_admin_user.name, not_data_visible.name, '', '', '', '', '0', 'No', '', 'Meters'],
        [school_group.name, '', school_group.default_issues_admin_user.name, not_visible.name, '', '', '', '', '0', 'No', '', 'Meters']
      ]
    )
  end
end

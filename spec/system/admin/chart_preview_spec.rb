require 'rails_helper'

describe 'Chart preview', type: :system do
  let!(:schools) { create_list(:school, 2, data_enabled: true) }

  before do
    sign_in(create(:admin))
    visit admin_path
  end

  it 'displays page, schools and charts' do
    click_on 'Chart preview'

    select schools.first.name, from: 'Choose school'
    select 'management_dashboard_group_by_week_electricity', from: 'Choose chart'
    fill_in 'Title', with: 'My title'
    fill_in 'Subtitle', with: 'My subtitle'
    fill_in 'Footer', with: 'My footer'
    click_on 'Run chart'

    within('.chart-wrapper') do
      expect(page).to have_content('My title')
      expect(page).to have_content('My subtitle')
      expect(page).to have_css('#chart_management_dashboard_group_by_week_electricity')
    end
    expect(page).to have_content('My footer')
  end
end

require 'rails_helper'

RSpec.describe 'alert type management', type: :system do

  let!(:admin)  { create(:user, role: 'admin')}

  let!(:gas_fuel_alert_type) { create(:alert_type, fuel_type: :gas, frequency: :termly, title: 'Your gas usage is too high', has_variables: true) }


  describe 'managing associated activities' do

    let!(:activity_category) { create(:activity_category)}
    let!(:activity_type_1) { create(:activity_type, name: 'Turn off the lights', activity_category: activity_category)}
    let!(:activity_type_2) { create(:activity_type, name: 'Turn down the heating', activity_category: activity_category)}

    before do
      sign_in(admin)
      visit root_path
      click_on 'Alert Types'
    end

    it 'assigns activity types to alerts via a checkbox' do

      click_on 'Your gas usage is too high'
      click_on 'Associated activity types'

      expect(page).to have_field('Turn off the lights', checked: false)
      expect(page).to have_field('Turn down the heating', checked: false)

      check 'Turn down the heating'

      click_on 'Update associated activity type', match: :first

      expect(page).to have_field('Turn off the lights', checked: false)
      expect(page).to have_field('Turn down the heating', checked: true)

      expect(gas_fuel_alert_type.activity_types).to match_array([activity_type_2])

    end
  end

  describe 'creating find out more copy' do

    before do
      sign_in(admin)
      visit root_path
      click_on 'Manage'
      click_on 'Alert Types'
    end

    it 'allows creation and editing of Find Out More content', js: true do

      click_on 'Your gas usage is too high'
      click_on 'Find Out More types'

      click_on 'New Find Out More type'

      fill_in 'Rating from', with: '0'
      fill_in 'Rating to', with: '10'
      fill_in 'Description', with: 'For schools with bad heating management'

      fill_in 'Dashboard title', with: 'Your gas usage is too high'
      fill_in 'Page title', with: 'You are using too much gas!'

      editor = find('trix-editor')
      editor.click.set('You are using too much gas! You need to do something about it.')

      click_on 'Create Find Out More'

      expect(gas_fuel_alert_type.find_out_more_types.size).to eq(1)
      find_out_more_type = gas_fuel_alert_type.find_out_more_types.first
      expect(find_out_more_type.content_versions.size).to eq(1)
      first_content = find_out_more_type.current_content
      expect(first_content.page_title).to eq('You are using too much gas!')

      click_on 'Edit'

      fill_in 'Page title', with: 'Stop using so much gas!'
      click_on 'Update Find Out More type'

      expect(find_out_more_type.content_versions.size).to eq(2)
      second_content = find_out_more_type.current_content
      expect(second_content.page_title).to eq('Stop using so much gas!')


    end
  end

end

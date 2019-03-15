require 'rails_helper'

RSpec.describe 'alert type management', type: :system do

  let!(:admin)  { create(:user, role: 'admin')}

  let!(:gas_fuel_alert_type) { create(:alert_type, fuel_type: :gas, frequency: :termly, title: 'Your gas usage is too high') }

  let!(:activity_category) { create(:activity_category)}
  let!(:activity_type_1) { create(:activity_type, name: 'Turn off the lights', activity_category: activity_category)}
  let!(:activity_type_2) { create(:activity_type, name: 'Turn down the heating', activity_category: activity_category)}

  describe 'managing associated activities' do

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

end

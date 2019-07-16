require 'rails_helper'

describe 'programme type management', type: :system do

  let!(:admin)  { create(:user, role: 'admin')}

  describe 'managing' do

    # let!(:alert_type_rating) { create(:alert_type_rating, alert_type: gas_fuel_alert_type)}
    # let!(:activity_category) { create(:activity_category)}
    # let!(:activity_type_1) { create(:activity_type, name: 'Turn off the lights', activity_category: activity_category)}
    # let!(:activity_type_2) { create(:activity_type, name: 'Turn down the heating', activity_category: activity_category)}

    before do
      sign_in(admin)
      visit root_path
      click_on 'Programme Types'
    end

    it 'allows the user to create a programme type' do
      click_on 'New Programme Type'
      fill_in 'Title', with: 'Super programme number 1'
      click_on 'Save'
      expect(page).to have_content('Programme Types')
      expect(page).to have_content('Super programme number 1')

      click_on 'Edit'
      fill_in 'Title', with: 'Super programme number 2'
      click_on 'Save'
      expect(page).to have_content('Programme Types')
      expect(page).to have_content('Super programme number 2')

      click_on 'Delete'
      expect(page).to have_content('There are no programme types')
    end
  end
end
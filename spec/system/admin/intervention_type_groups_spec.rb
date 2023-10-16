require 'rails_helper'

RSpec.describe 'Intervention Type Groups', type: :system do
  let!(:admin)                    { create(:admin) }
  let!(:intervention_type_group)  { create(:intervention_type_group)}

  context 'when logged in as admin' do
    before do
      sign_in(admin)
      visit root_path
      click_on 'Admin'
    end

    it 'I can view and edit the categories' do
      click_on 'Intervention Categories'
      expect(page).to have_content(intervention_type_group.name)
      expect(page).to have_content(intervention_type_group.description)

      new_description = 'Some useful text'
      new_name = "Upgrade equipment"

      click_on 'Edit'
      fill_in :intervention_type_group_description_en, with: new_description
      fill_in :intervention_type_group_name_en, with: ''
      click_on 'Update Intervention type group'

      expect(page).to have_content("can't be blank")
      fill_in :intervention_type_group_name_en, with: new_name
      uncheck 'Active'

      click_on 'Update Intervention type group'

      expect(page).to have_content('Intervention Categories')
      expect(page).to have_content(new_name)
      expect(page).to have_content(new_description)
      expect(page).to have_content("No")
    end

    it 'I can create a new intervention type group' do
      click_on 'Intervention Categories'
      click_on 'New intervention category'

      new_description = 'Some useful text'
      new_name = "Upgrade equipment"

      fill_in :intervention_type_group_name_en, with: ''
      fill_in :intervention_type_group_description_en, with: new_description
      expect { click_on 'Create Intervention type group' }.to change { InterventionTypeGroup.count }.by(0)
      expect(page).to have_content("can't be blank")
      fill_in :intervention_type_group_name_en, with: new_name
      expect { click_on 'Create Intervention type group' }.to change { InterventionTypeGroup.count }.by(1)

      expect(page).to have_content(new_name)
      expect(page).to have_content(new_description)
    end
  end

  describe 'when not logged in' do
    it 'does not authorise viewing' do
      visit admin_intervention_type_groups_path
      expect(page).to have_content('You need to sign in or sign up before continuing.')
    end
  end
end

require 'rails_helper'

describe 'advice page management', type: :system do
  let(:school)        { create(:school) }
  let(:admin)         { create(:admin, school: school) }

  let!(:advice_page) { create(:advice_page, key: 'baseload-summary') }

  before do
    sign_in(admin)
  end

  describe 'managing the advice pages' do
    before do
      visit admin_path
      click_on 'Advice Pages'
    end

    it 'allows the user to list and edit the advice pages' do
      expect(page).to have_content('Manage advice pages')
      expect(page).to have_content('baseload-summary')

      click_on 'Edit'

      expect(page).to have_content('Editing Advice Page: baseload-summary')

      fill_in_trix '#advice_page_learn_more_en', with: 'english text here'
      fill_in_trix '#advice_page_learn_more_cy', with: 'welsh text here'
      check 'Restricted'

      click_on 'Save'

      expect(page).to have_content('Advice Page updated')

      advice_page.reload
      expect(advice_page.restricted).to be_truthy
      expect(advice_page.learn_more.to_s).to include('english text here')
      expect(advice_page.learn_more_en.to_s).to include('english text here')
      expect(advice_page.learn_more_cy.to_s).to include('welsh text here')
    end
  end

  describe 'managing associated activities' do
    let!(:activity_category) { create(:activity_category)}
    let!(:activity_type_1) { create(:activity_type, name: 'Turn off the lights', activity_category: activity_category)}
    let!(:activity_type_2) { create(:activity_type, name: 'Turn down the heating', activity_category: activity_category)}

    before do
      visit admin_path
      click_on 'Advice Pages'
    end

    it 'allows admin user to manage the activities' do
      click_on 'Activity types (0)'

      expect(page.find_field('Turn off the lights').value).to be_blank
      expect(page.find_field('Turn down the heating').value).to be_blank

      fill_in 'Turn down the heating', with: '1'

      click_on 'Update associated activity type', match: :first
      click_on 'Activity types'

      expect(page.find_field('Turn off the lights').value).to be_blank
      expect(page.find_field('Turn down the heating').value).to eq('1')

      expect(advice_page.activity_types).to match_array([activity_type_2])
      expect(advice_page.advice_page_activity_types.first.position).to eq(1)
    end
  end

  describe 'managing associated actions' do
    let!(:intervention_type_group) { create(:intervention_type_group) }
    let!(:intervention_type_1) { create(:intervention_type, name: 'Install cladding', intervention_type_group: intervention_type_group)}
    let!(:intervention_type_2) { create(:intervention_type, name: 'Check the boiler', intervention_type_group: intervention_type_group)}

    before do
      visit admin_path
      click_on 'Advice Pages'
    end

    it 'allows admin user to manage the actions' do
      click_on 'Actions (0)'

      expect(page.find_field('Install cladding').value).to be_blank
      expect(page.find_field('Check the boiler').value).to be_blank

      fill_in 'Check the boiler', with: '1'

      click_on 'Update associated actions', match: :first
      click_on 'Actions (1)'

      expect(page.find_field('Install cladding').value).to be_blank
      expect(page.find_field('Check the boiler').value).to eq('1')

      expect(advice_page.intervention_types).to match_array([intervention_type_2])
      expect(advice_page.advice_page_intervention_types.first.position).to eq(1)
    end
  end
end

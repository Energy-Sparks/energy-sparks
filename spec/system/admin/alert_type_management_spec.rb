require 'rails_helper'

describe 'alert type management', type: :system do
  let!(:admin)                    { create(:admin) }

  let(:gas_fuel_alert_type_title) { 'Your gas usage is too high' }
  let!(:gas_fuel_alert_type)      { create(:alert_type, fuel_type: :gas, frequency: :termly, title: gas_fuel_alert_type_title, has_ratings: true) }
  let!(:school)                   { create(:school, :with_school_group) }

  before do
    sign_in(admin)
    visit root_path
    click_on 'Manage'
    click_on 'Admin'
    click_on 'Alert Types'
  end

  describe 'schools' do
    before(:each) do
      click_on gas_fuel_alert_type_title

      within('ul.alert-type') do
        click_on 'School alert type exclusions'
      end
      expect(page).to have_content('No school exclusions for this alert')
    end

    it 'can see a list of schools' do
      click_on 'Manage exclusions'
      expect(page).to have_content(school.name)
    end

    it 'can add and delete some exclusions with the right reasons' do
      school_2 = create(:school, :with_school_group)
      click_on 'Manage exclusions'
      check school.name
      reason_1 = 'Super massive heating model'
      fill_in "school_reasons_#{school.id}", with: reason_1

      check school_2.name
      reason_2 = 'Conditional editing'
      fill_in "school_reasons_#{school_2.id}", with: reason_2

      expect { click_on "Create exclusions" }.to change { SchoolAlertTypeExclusion.count }.by(2)
      expect(page).to_not have_content('No school exclusions for this alert')

      within 'table' do
        expect(page).to have_content(school.name)
        expect(page).to have_content(reason_1)
      end

      within('tr', text: school.name) do
        expect { click_on 'Delete', match: :first }.to change { SchoolAlertTypeExclusion.count }.by(-1)
      end

      within 'table' do
        expect(page).to_not have_content(school.name)
        expect(page).to_not have_content(reason_1)
        expect(page).to have_content(school_2.name)
        expect(page).to have_content(reason_2)
      end
    end
  end

  describe 'general editing' do
    it 'allows fields to be edited and validates title', js: true do
      click_on gas_fuel_alert_type_title
      click_on 'Edit'

      fill_in 'Title', with: ''
      click_on 'Update Alert type'

      expect(page).to have_content("Title *\ncan't be blank")

      new_title = 'New title'
      new_description = 'New description'

      fill_in 'Title', with: new_title
      fill_in_trix with: new_description
      choose 'Weekly'
      click_on 'Update Alert type'

      expect(page).to have_content('Alert type updated')
      expect(page).to have_content(new_title)
      expect(page).to have_content(new_description)
      expect(page).to have_content('Weekly')
    end
  end
end

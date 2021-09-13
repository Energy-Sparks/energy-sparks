require 'rails_helper'


describe 'adding interventions' do

  let!(:school)     { create(:school, :with_calendar, solar_pv_tuos_area: create(:solar_pv_tuos_area)) }
  let!(:user)       { create(:school_admin, school: school)}

  let!(:boiler_intervention){ create :intervention_type, title: 'Changed boiler', summary: 'Old boiler bad, new boiler good' }

  context 'using the management pages' do

    before(:each) do
      sign_in(user)
    end

    it 'allows a user to add and edit interventions', js: true do
      visit management_school_path(school)

      click_on 'Record an action'

      click_on boiler_intervention.intervention_type_group.title

      choose 'Changed boiler'
      fill_in_trix with: 'We changed to a more efficient boiler'

      click_on 'Continue'

      expect(page).to have_content('When did you do it?')
      fill_in 'observation_at', with: '01/07/2019', visible: false

      find('input#observation_at').native.send_keys(:tab)

      click_on 'Continue'

      click_on 'Confirm'

      intervention = school.observations.intervention.first
      expect(intervention.intervention_type).to eq(boiler_intervention)
      expect(intervention.at.to_date).to eq(Date.new(2019, 7, 1))

      within '.application' do
        click_on 'Edit'
      end

      expect(page).to have_content('What did you do?')
      click_on 'Continue'

      fill_in 'observation_at', with: '20/06/2019', visible: false
      find('input#observation_at').native.send_keys(:tab)

      click_on 'Continue'

      click_on 'Confirm'

      intervention.reload
      expect(intervention.at.to_date).to eq(Date.new(2019, 6, 20))

      click_on 'Changed boiler'
      expect(page).to have_content('We changed to a more efficient boiler')
    end

    it 'destroys interventions' do
      intervention = create(:observation, :intervention, school: school)
      school.calendar.update(based_on: create(:regional_calendar, :with_academic_years))

      visit management_school_path(school)
      click_on 'View all actions'

      expect{
        click_on 'Delete'
      }.to change{Observation.count}.from(1).to(0)
    end

  end

  context 'using the public pages' do

    before(:each) do
      sign_in(user)
    end

    it 'allows a user to add and interventions' do
      visit intervention_type_groups_path

      click_on 'Changed boiler'

      click_on "Record this action"

      fill_in_trix with: 'We changed to a more efficient boiler'
      fill_in 'observation_at', with: '01/07/2019'

      click_on 'Save'

      intervention = school.observations.intervention.last
      expect(intervention.intervention_type).to eq(boiler_intervention)
      expect(intervention.at.to_date).to eq(Date.new(2019, 7, 1))

      click_on 'Changed boiler'
      expect(page).to have_content('We changed to a more efficient boiler')
    end
  end

  context 'using the public pages' do
    it 'allows public user to view interventions' do
      visit intervention_type_groups_path
      expect(page).to have_content(boiler_intervention.intervention_type_group.title)
      click_on 'Changed boiler'
      expect(page).to have_content('Old boiler bad, new boiler good')
      click_on "All #{boiler_intervention.intervention_type_group.title} actions"
      expect(page).to have_content(boiler_intervention.intervention_type_group.title)
    end
  end
end

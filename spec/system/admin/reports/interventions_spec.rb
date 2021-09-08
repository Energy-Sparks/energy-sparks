require 'rails_helper'

describe 'Interventions report', type: :system do

  let!(:admin)          { create(:admin) }
  let!(:intervention)   { create(:observation, :intervention) }

  context 'as an admin' do
    before(:each) do
      sign_in(admin)
      visit root_path
      click_on 'Manage'
      click_on 'Reports'
    end

    it 'allows me to see recent interventions' do
      click_on "Recently recorded interventions"
      expect(page).to have_content("Recently recorded interventions")
      expect(page).to have_content(intervention.school.name)
      expect(page).to have_content(intervention.intervention_type.title)
    end
  end
end

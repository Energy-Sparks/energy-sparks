require 'rails_helper'

describe 'Interventions report', type: :system do
  let!(:admin)          { create(:admin) }
  let!(:intervention)   { create(:observation, :intervention, school: create(:school, :with_school_group)) }

  context 'as an admin' do
    before do
      sign_in(admin)
      visit root_path
      click_on 'Manage'
      click_on 'Reports'
    end

    it 'allows me to see recent interventions' do
      click_on 'Recently recorded interventions'
      expect(page).to have_text('Recently recorded interventions')
      expect(page).to have_text(intervention.school.name)
      expect(page).to have_text(intervention.intervention_type.name)
    end
  end
end

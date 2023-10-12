require 'rails_helper'

RSpec.describe "intervention type groups", type: :system do
  let!(:intervention_type_1) { create(:intervention_type) }
  let!(:intervention_type_2) { create(:intervention_type) }

  context 'as not logged in user' do
    describe 'intervention type groups can be viewed' do
      before do
        visit intervention_type_groups_path
      end

      it 'not including recommended actions' do
        expect(page).not_to have_content('Recommended for your school')
      end
    end
  end

  context 'as logged in user' do
    let(:school)  { create(:school) }
    let(:user)    { create(:user, school: school) }

    describe 'intervention type groups can be viewed' do
      before do
        sign_in(user)
        visit intervention_type_groups_path
      end

      it 'shows recommended actions' do
        expect(page).to have_content('Recommended for your school')
        expect(page).to have_content(intervention_type_1.name)
        expect(page).to have_content(intervention_type_2.name)
      end

      it 'links to all suggestions' do
        click_on 'View all suggestions'
        expect(page).to have_content('A collection of 2 actions that are suggested for your school')
        expect(page).to have_content(intervention_type_1.name)
        expect(page).to have_content(intervention_type_2.name)
      end
    end
  end
end

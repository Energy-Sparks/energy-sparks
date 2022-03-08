require 'rails_helper'

RSpec.describe "intervention type groups", type: :system do

  let!(:intervention_type_1) { create(:intervention_type) }
  let!(:intervention_type_2) { create(:intervention_type) }

  let(:school)  { create(:school) }

  context 'as admin' do
    let(:user)    { create(:admin, school: school) }

    describe 'intervention type groups can be viewed' do
      before(:each) do
        sign_in(user)
        visit intervention_type_groups_path
      end

      it 'shows recommended actions' do
        expect(page).to have_content('Recommended for your school')
        expect(page).to have_content(intervention_type_1.title)
        expect(page).to have_content(intervention_type_2.title)
      end
    end
  end
end

require 'rails_helper'

RSpec.describe 'intervention type groups', type: :system do
  let!(:intervention_type_1) { create(:intervention_type) }
  let!(:intervention_type_2) { create(:intervention_type) }

  let(:user) { }

  before do
    sign_in(user) if user.present?
    visit intervention_type_groups_path
  end

  context 'when user is not logged in' do
    it_behaves_like 'a recommended prompt', displayed: false
  end

  context 'when user is logged in' do
    context 'without a school' do
      let(:school) { }
      let(:user) { create :admin, school: school }

      it_behaves_like 'a recommended prompt', displayed: false
    end

    context 'with a school' do
      let(:school) { create :school }
      let(:user) { create :pupil, school: school }

      it_behaves_like 'a recommended prompt'
    end
  end

  describe 'viewing old recommended page' do
    before do
      sign_in(user)
      visit recommended_intervention_type_groups_path
    end

    context 'when user has a school' do
      let(:user) { create(:staff, school: create(:school)) }

      it 'redirects to new recommemndations page for school' do
        expect(page).to have_content('Recommended activities and actions')
      end
    end

    context 'when user has no school' do
      let(:user) { create(:admin, school: nil) }

      it 'redirects to the intervention type groups index' do
        expect(page).to have_content('Explore energy saving actions')
      end
    end
  end
end

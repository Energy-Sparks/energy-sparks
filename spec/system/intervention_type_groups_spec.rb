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
end

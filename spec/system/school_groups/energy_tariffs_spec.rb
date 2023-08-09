require 'rails_helper'

describe 'energy tariffs', type: :system do
  let!(:school_group)          { create(:school_group, public: true) }
  let!(:school) { create_active_school(name: "Big School", school_group: school_group)}

  around do |example|
    ClimateControl.modify FEATURE_FLAG_USE_NEW_ENERGY_TARIFFS: 'true' do
      ClimateControl.modify FEATURE_FLAG_ENHANCED_SCHOOL_GROUP_DASHBOARD: "true" do
        example.run
      end
    end
  end

  context 'as an admin' do
    let!(:current_user) { create(:admin) }

    it_behaves_like "the school group energy tariff forms well navigated"
  end

  # context 'as a school admin' do
  #   let!(:current_user) { create(:school_admin, school: school) }
  # end

  context 'as a school user' do
    let!(:current_user) { create(:user, school: school) }
    before(:each) { sign_in(current_user) }

    context 'does not allow access to the energy tariffs page' do
      it 'redirects to the school index page' do
        visit school_group_energy_tariffs_path(school_group)
        expect(current_path).to eq("/schools/#{school.slug}")
      end
    end
  end

  context 'with no signed in user' do
    context 'does not allow access to the energy tariffs page' do
      it 'redirects to the sign in page' do
        visit school_group_energy_tariffs_path(school_group)
        expect(current_path).to eq('/users/sign_in')
      end
    end
  end
end

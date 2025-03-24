require 'rails_helper'

describe 'school energy tariffs', type: :system do
  around do |example|
    ClimateControl.modify FEATURE_FLAG_NEW_ENERGY_TARIFF_EDITOR: 'true' do
      example.run
    end
  end

  describe 'when creating tariffs' do
    include_context 'a school with meters'

    context 'as an admin user' do
      let!(:current_user) { create(:admin) }

      it_behaves_like 'a school tariff editor'
    end

    context 'as a school admin user' do
      let!(:current_user) { create(:school_admin, school: school) }

      it_behaves_like 'a school tariff editor'
    end

    context 'as a group_admin user for this schools group' do
      let!(:school_group) { create(:school_group) }
      let!(:school)       { create_active_school(school_group: school_group)}
      let!(:current_user) { create(:group_admin, school_group: school_group) }

      it_behaves_like 'a school tariff editor'
    end

    context 'as a group_admin user' do
      let!(:current_user) { create(:group_admin) }

      context 'does not allow access to the energy tariffs page' do
        it 'redirects to the school index page' do
          visit school_energy_tariffs_path(school)
          expect(page).to have_current_path('/users/sign_in', ignore_query: true)
        end
      end
    end

    context 'as a guest user' do
      let!(:current_user) { create(:guest) }
      let(:path)          { school_energy_tariffs_path(school) }

      before { sign_in(current_user) }

      it_behaves_like 'the user does not have access to the tariff editor'
    end

    context 'as a pupil user' do
      let!(:current_user) { create(:pupil, school: school) }
      before { sign_in(current_user) }

      let(:path) { school_energy_tariffs_path(school) }

      it_behaves_like 'the user does not have access to the tariff editor'
    end

    context 'as a school_onboarding user' do
      let!(:current_user) { create(:onboarding_user, school: school) }
      let(:path)          { school_energy_tariffs_path(school) }

      before { sign_in(current_user) }

      it_behaves_like 'the user does not have access to the tariff editor'
    end

    context 'as a staff user' do
      let!(:current_user) { create(:staff, school: school) }
      let(:path)          { school_energy_tariffs_path(school) }

      before { sign_in(current_user) }

      it_behaves_like 'the user does not have access to the tariff editor'
    end

    context 'as a non school user' do
      let!(:school_2)     { create_active_school }
      let!(:current_user) { create(:user, school: school_2) }
      let(:path)          { school_energy_tariffs_path(school) }

      before { sign_in(current_user) }

      it_behaves_like 'the user does not have access to the tariff editor'
    end

    context 'as a non school admin user' do
      let!(:school_2)     { create_active_school }
      let!(:current_user) { create(:school_admin, school: school_2) }
      let(:path)          { school_energy_tariffs_path(school) }

      before { sign_in(current_user) }

      it_behaves_like 'the user does not have access to the tariff editor'
    end

    context 'with no signed in user' do
      let!(:current_user) { nil }
      let(:path)          { school_energy_tariffs_path(school) }

      it_behaves_like 'the user does not have access to the tariff editor'
    end
  end
end

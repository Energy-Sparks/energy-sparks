require 'rails_helper'

describe 'school group energy tariffs', type: :system do
  let!(:school_group) { create(:school_group, public: true) }

  around do |example|
    ClimateControl.modify FEATURE_FLAG_NEW_ENERGY_TARIFF_EDITOR: 'true' do
      example.run
    end
  end

  before { school_group.schools.reload }

  context 'as an admin user' do
    let!(:current_user) { create(:admin) }

    it_behaves_like 'a school group energy tariff editor'
  end

  context 'as a group_admin user' do
    let(:current_user) { create(:user, role: :group_admin, school_group: school_group)}

    it_behaves_like 'a school group energy tariff editor'
  end

  context 'as a group_admin user of a different group' do
    let!(:school_group_2) { create(:school_group, public: true) }
    let(:current_user) { create(:user, role: :group_admin, school_group: school_group_2)}
    let(:path) { school_group_energy_tariffs_path(school_group) }

    before { sign_in(current_user) }

    it_behaves_like 'the user does not have access to the tariff editor'
  end

  context 'as a guest user' do
    let!(:current_user) { create(:guest) }
    let(:path)          { school_group_energy_tariffs_path(school_group) }

    before { sign_in(current_user) }

    it_behaves_like 'the user does not have access to the tariff editor'
  end

  context 'as a pupil user' do
    let!(:current_user) { create(:pupil) }
    let(:path)          { school_group_energy_tariffs_path(school_group) }

    before { sign_in(current_user) }

    it_behaves_like 'the user does not have access to the tariff editor'
  end

  context 'as a school admin user' do
    let!(:current_user) { create(:school_admin) }
    let(:path)          { school_group_energy_tariffs_path(school_group) }

    before              { sign_in(current_user) }

    it_behaves_like 'the user does not have access to the tariff editor'
  end

  context 'as a school_onboarding user' do
    let!(:current_user) { create(:onboarding_user) }
    let(:path)          { school_group_energy_tariffs_path(school_group) }

    before { sign_in(current_user) }

    it_behaves_like 'the user does not have access to the tariff editor'
  end

  context 'as a staff user' do
    let!(:current_user) { create(:staff) }
    let(:path)          { school_group_energy_tariffs_path(school_group) }

    before { sign_in(current_user) }

    it_behaves_like 'the user does not have access to the tariff editor'
  end

  context 'with no signed in user' do
    let!(:current_user) { nil }
    let(:path)          { school_group_energy_tariffs_path(school_group) }

    it_behaves_like 'the user does not have access to the tariff editor'
  end
end

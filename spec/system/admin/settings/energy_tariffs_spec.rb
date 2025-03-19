require 'rails_helper'

describe 'site settings energy tariffs', type: :system do
  around do |example|
    ClimateControl.modify FEATURE_FLAG_NEW_ENERGY_TARIFF_EDITOR: 'true' do
      example.run
    end
  end

  context 'as an admin user' do
    let!(:current_user) { create(:admin) }

    before { sign_in(current_user) }

    it_behaves_like 'the site settings energy tariff editor'
  end

  context 'as a group_admin user' do
    let!(:current_user) { create(:group_admin) }
    let(:path)          { admin_settings_energy_tariffs_path }

    before              { sign_in(current_user) }

    it_behaves_like 'the user does not have access to the tariff editor'
  end

  context 'as a guest user' do
    let!(:current_user) { create(:guest) }
    let(:path)          { admin_settings_energy_tariffs_path }

    before              { sign_in(current_user) }

    it_behaves_like 'the user does not have access to the tariff editor'
  end

  context 'as a pupil user' do
    let!(:current_user) { create(:pupil) }
    let(:path)          { admin_settings_energy_tariffs_path }

    before              { sign_in(current_user) }

    it_behaves_like 'the user does not have access to the tariff editor'
  end

  context 'as a school admin user' do
    let!(:current_user) { create(:school_admin) }
    let(:path)          { admin_settings_energy_tariffs_path }

    before              { sign_in(current_user) }

    it_behaves_like 'the user does not have access to the tariff editor'
  end

  context 'as a school_onboarding user' do
    let!(:current_user) { create(:onboarding_user) }
    let(:path)          { admin_settings_energy_tariffs_path }

    before              { sign_in(current_user) }

    it_behaves_like 'the user does not have access to the tariff editor'
  end

  context 'as a staff user' do
    let!(:current_user) { create(:staff) }
    let(:path)          { admin_settings_energy_tariffs_path }

    before              { sign_in(current_user) }

    it_behaves_like 'the user does not have access to the tariff editor'
  end

  context 'with no signed in user' do
    let!(:current_user) { nil }
    let(:path)          { admin_settings_energy_tariffs_path }

    it_behaves_like 'the user does not have access to the tariff editor'
  end
end

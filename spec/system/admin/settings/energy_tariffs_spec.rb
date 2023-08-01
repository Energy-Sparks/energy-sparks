require 'rails_helper'

describe 'site settings energy tariffs', type: :system do
  let!(:school) { create_active_school(name: "Big School")}

  around do |example|
    ClimateControl.modify FEATURE_FLAG_USE_NEW_ENERGY_TARIFFS: 'true' do
      example.run
    end
  end

  context 'as an admin' do
    let!(:current_user) { create(:admin) }
    before(:each) { sign_in(current_user) }

    context 'allows access to the admin site settings energy tariffs page' do
      it 'redirects to the school index page' do
        visit admin_settings_energy_tariffs_path
        expect(current_path).to eq("/admin/settings/energy_tariffs")
      end
    end
  end

  context 'as a school admin' do
    let!(:current_user) { create(:school_admin, school: school) }
    before(:each) { sign_in(current_user) }

    context 'does not allow access to the admin site settings energy tariffs page' do
      it 'redirects to the school index page' do
        visit admin_settings_energy_tariffs_path
        expect(current_path).to eq("/schools/#{school.slug}")
      end
    end
  end

  context 'as a school user' do
    let!(:current_user) { create(:user, school: school) }
    before(:each) { sign_in(current_user) }

    context 'does not allow access to the admin site settings energy tariffs page' do
      it 'redirects to the school index page' do
        visit admin_settings_energy_tariffs_path
        expect(current_path).to eq("/schools/#{school.slug}")
      end
    end
  end

  context 'with no signed in user' do
    context 'does not allow access to the admin site settings energy tariffs page' do
      it 'redirects to the sign in page' do
        visit admin_settings_energy_tariffs_path
        expect(current_path).to eq('/users/sign_in')
      end
    end
  end
end
